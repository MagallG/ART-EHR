# modules/patients.py
from db.database import Database

class PatientsModel:
    def __init__(self, db_config):
        self.db = Database(db_config)

    def list_patients(self):
        sql = "SELECT Patient_ID, Sur_name, Other_name, Gender, DOB, Date_Registered FROM Patient_Records"
        rows = self.db.query(sql)
        return [f"{r['Patient_ID']} | {r['Sur_name']} {r.get('Other_name') or ''} | {r['Gender']} | {r['DOB']}" for r in rows]

    def list_patients_raw(self):
        sql = "SELECT Patient_ID, Sur_name, Other_name, Gender, DOB, Date_Registered FROM Patient_Records"
        return self.db.query(sql)

    def get_patient(self, patient_id):
        sql = "SELECT * FROM Patient_Records WHERE Patient_ID = ?"
        rows = self.db.query(sql, (patient_id,))
        return rows[0] if rows else None

    def add_patient(self, p):
        sql = """INSERT INTO Patient_Records
            (Patient_ID, Sur_name, Other_name, Gender, DOB, Nationality, Address, Contact, NIN, NOK, NOK_Contact)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"""
        params = (
            p.get('Patient_ID'), p.get('Sur_name'), p.get('Other_name'), p.get('Gender'), p.get('DOB'),
            p.get('Nationality'), p.get('Address'), p.get('Contact'), p.get('NIN'), p.get('NOK'), p.get('NOK_Contact')
        )
        self.db.execute(sql, params)

    def update_patient(self, patient_id, p):
        sql = """UPDATE Patient_Records SET
            Sur_name=?, Other_name=?, Gender=?, DOB=?, Nationality=?, Address=?, Contact=?, NIN=?, NOK=?, NOK_Contact=?
            WHERE Patient_ID=?"""
        params = (
            p.get('Sur_name'), p.get('Other_name'), p.get('Gender'), p.get('DOB'), p.get('Nationality'),
            p.get('Address'), p.get('Contact'), p.get('NIN'), p.get('NOK'), p.get('NOK_Contact'), patient_id
        )
        self.db.execute(sql, params)

    def delete_patient(self, patient_id):
        sql = "DELETE FROM Patient_Records WHERE Patient_ID = ?"
        self.db.execute(sql, (patient_id,))
