# hospital_app.py
import hashlib
import threading
import csv
from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, NoTransition
from kivy.properties import StringProperty, ListProperty
from kivy.clock import Clock

# Models
from modules.patients import PatientsModel
from modules.staff import StaffModel
from modules.visits import VisitsModel
from modules.labs import LabsModel
from modules.counselling import CounsellingModel
from modules.analytics import AnalyticsModel

# Load KV file
Builder.load_file('hospital.kv')

class RootScreenManager(ScreenManager):
    pass

class HospitalApp(App):
    status_message = StringProperty("")
    patient_data = ListProperty([])
    staff_list = ListProperty([])

    def build(self):
        # === EDIT THESE CONNECTION DETAILS BEFORE RUNNING ===
        self.db_config = {
            'server': r'localhost\\SQLEXPRESS',
            'database': 'ART_ehr',
            'uid': None,
            'pwd': None,
            'driver': '{ODBC Driver 17 for SQL Server}'
        }
        # ====================================================

        # Initialize models
        self.patients = PatientsModel(self.db_config)
        self.staff = StaffModel(self.db_config)
        self.visits = VisitsModel(self.db_config)
        self.labs = LabsModel(self.db_config)
        self.counselling = CounsellingModel(self.db_config)
        self.analytics = AnalyticsModel(self.db_config)

        # preload async
        self.async_call(self._load_initial_data)

        sm = RootScreenManager(transition=NoTransition())
        return sm

    # ----------------- Thread helper -----------------
    def async_call(self, fn, callback=None, *args, **kwargs):
        """Run fn in background thread. If callback provided, schedule callback(result) on main thread."""
        def _target():
            try:
                res = fn(*args, **kwargs)
                if callback:
                    Clock.schedule_once(lambda dt: callback(res), 0)
            except Exception as e:
                # Schedule error to UI
                Clock.schedule_once(lambda dt: self._set_status(f"Background error: {err}"), 0)
        threading.Thread(target=_target, daemon=True).start()

    def _set_status(self, msg):
        self.status_message = msg

    # ----------------- Initial load -----------------
    def _load_initial_data(self):
        patients = self.patients.list_patients_raw()
        staff = self.staff.list_staff_raw()
        return {'patients': patients, 'staff': staff}

    def _initial_loaded(self, data):
        self.patient_data = [f"{r['Patient_ID']} | {r['Sur_name']} {r.get('Other_name') or ''} | {r['Gender']} | {r['DOB']}" for r in data['patients']]
        self.staff_list = [f"{r['Staff_ID']} | {r['Surname']} {r.get('other_name') or ''}" for r in data['staff']]
        self.status_message = f"Loaded {len(self.patient_data)} patients and {len(self.staff_list)} staff"

    # ----------------- Patient wrappers (async) -----------------
    def refresh_patients(self):
        def fn():
            return self.patients.list_patients_raw()
        def cb(rows):
            self.patient_data = [f"{r['Patient_ID']} | {r['Sur_name']} {r.get('Other_name') or ''} | {r['Gender']} | {r['DOB']}" for r in rows]
            self.status_message = f"Loaded {len(rows)} patients"
        self.async_call(fn, cb)

    def add_patient(self, patient_dict):
        def fn():
            self.patients.add_patient(patient_dict)
            return True
        def cb(res):
            self.status_message = "Patient added."
            self.refresh_patients()
        self.async_call(fn, cb)

    def update_patient(self, patient_id, patient_dict):
        def fn():
            self.patients.update_patient(patient_id, patient_dict)
            return True
        def cb(res):
            self.status_message = "Patient updated."
            self.refresh_patients()
        self.async_call(fn, cb)

    def delete_patient(self, patient_id):
        def fn():
            self.patients.delete_patient(patient_id)
            return True
        def cb(res):
            self.status_message = f"Deleted {patient_id}"
            self.refresh_patients()
        self.async_call(fn, cb)

    # ----------------- Staff / Login -----------------
    def login(self, staff_id, password):
        def fn():
            hashed = hashlib.sha256(password.encode('utf-8')).hexdigest()
            return self.staff.authenticate(staff_id, hashed)
        def cb(res):
            if res:
                self.status_message = f"Welcome {staff_id}"
                self.root.current = 'patients'
            else:
                self.status_message = "Login failed"
        self.async_call(fn, cb)

    def create_staff_user(self, staff_dict, raw_password):
        def fn():
            hashed = hashlib.sha256(raw_password.encode('utf-8')).hexdigest()
            self.staff.add_staff(staff_dict, hashed)
            return True
        def cb(res):
            self.status_message = "Staff user created."
            self.async_call(
    lambda: self.staff.list_staff_raw(),
    lambda rows: setattr(self, 'staff_list', [f"{r['Staff_ID']} | {r['Surname']}" for r in rows]))
        self.async_call(fn,cb)

    # ----------------- Analytics (async) -----------------
    def load_monthly_vl(self):
        def fn():
            return self.analytics.monthly_vl()
        def cb(rows):
            # rows is list of dicts
            items = [f"{r['Month']} - Tested: {r['Total_Tested']} Suppressed: {r['Suppressed']} ({r['Percent_Suppressed']}%)" for r in rows]
            # populate analytics list in KV via data list of dicts
            try:
                analytics_list = self.root.ids.analytics_list
                analytics_list.clear_widgets()
            except Exception:
                pass
            # schedule update to Recycle view-like list
            Clock.schedule_once(lambda dt: self._populate_analytics(items), 0)
        self.async_call(fn, cb)

    def _populate_analytics(self, items):
        # Replace the analytics_list GridLayout children with Labels
        grid = self.root.ids.analytics_list
        grid.clear_widgets()
        from kivy.uix.label import Label
        for it in items:
            grid.add_widget(Label(text=it, size_hint_y=None, height=28))

    def export_monthly_vl_csv(self, path):
        def fn():
            rows = self.analytics.monthly_vl()
            # write CSV
            with open(path, 'w', newline='', encoding='utf-8') as f:
                writer = csv.writer(f)
                if rows:
                    writer.writerow(rows[0].keys())
                    for r in rows:
                        writer.writerow([r[k] for k in rows[0].keys()])
            return path
        def cb(p):
            self.status_message = f"CSV exported to {p}"
        self.async_call(fn, cb)

    # Convenience small wrapper to run initial load on app start
    def on_start(self):
        # schedule callback after build to set initial data into UI
        def handle(data):
            self._initial_loaded(data)
        self.async_call(self._load_initial_data, lambda data: handle(data))

if __name__ == '__main__':
    HospitalApp().run()


