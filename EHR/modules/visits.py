# modules/visits.py
from db.database import Database

class VisitsModel:
    def __init__(self, db_config):
        self.db = Database(db_config)

    def list_visits(self, limit=100):
        sql = "SELECT Patient_ID, Staff_ID, Date_of_Visit, ART_Adherence, Refilled FROM Visit_Info ORDER BY Date_of_Visit DESC"
        return self.db.query(sql)

    def add_visit(self, v):
        sql = """INSERT INTO Visit_Info
            (Patient_ID, Staff_ID, Date_of_Visit, Appointment, Last_Scheduled_Appointment, ART_Adherence, ARV_sideEffects, TPT_Given, TPT_regimen_Given, Refilled, MMD_given, Due_for_bleeding, Bleeding_needed, Bleeding_note, Councelling_note, Clinical_notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""
        params = (
            v.get('Patient_ID'), v.get('Staff_ID'), v.get('Date_of_Visit'), v.get('Appointment'),
            v.get('Last_Scheduled_Appointment'), v.get('ART_Adherence'), v.get('ARV_sideEffects'),
            v.get('TPT_Given'), v.get('TPT_regimen_Given'), v.get('Refilled'), v.get('MMD_given'),
            v.get('Due_for_bleeding'), v.get('Bleeding_needed'), v.get('Bleeding_note'),
            v.get('Councelling_note'), v.get('Clinical_notes')
        )
        self.db.execute(sql, params)
