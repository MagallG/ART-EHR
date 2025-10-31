# modules/counselling.py
from db.database import Database

class CounsellingModel:
    def __init__(self, db_config):
        self.db = Database(db_config)

    def list_counselling(self):
        sql = "SELECT Councel_no, Patient_ID, Reason_fr_cnsl, Councelling_done, Outcome_if_Yes FROM Counselling ORDER BY Councel_no DESC"
        return self.db.query(sql)

    def add_counsel(self, c):
        sql = """INSERT INTO Counselling
            (Patient_ID, Reason_fr_cnsl, Councelling_done, Outcome_if_Yes, Reason_if_No, Next_Appointment)
            VALUES (?, ?, ?, ?, ?, ?)"""
        params = (
            c.get('Patient_ID'), c.get('Reason_fr_cnsl'), c.get('Councelling_done'),
            c.get('Outcome_if_Yes'), c.get('Reason_if_No'), c.get('Next_Appointment')
        )
        self.db.execute(sql, params)
