# modules/labs.py
from db.database import Database

class LabsModel:
    def __init__(self, db_config):
        self.db = Database(db_config)

    def list_labs(self):
        sql = "SELECT Lab_No, Patient_ID, Test_Ordered, Sample_taken, Result FROM Labs ORDER BY Lab_No DESC"
        return self.db.query(sql)

    def add_lab(self, lab):
        sql = """INSERT INTO Labs
            (Patient_ID, Test_Ordered, Sample_taken, Result, Reason_not_bled)
            VALUES (?, ?, ?, ?, ?)"""
        params = (
            lab.get('Patient_ID'), lab.get('Test_Ordered'), lab.get('Sample_taken'),
            lab.get('Result'), lab.get('Reason_not_bled')
        )
        self.db.execute(sql, params)
