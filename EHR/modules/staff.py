# modules/staff.py
from db.database import Database

class StaffModel:
    def __init__(self, db_config):
        self.db = Database(db_config)

    def list_staff_minimal(self):
        sql = "SELECT Staff_ID, Surname, other_name, Department FROM Staff"
        rows = self.db.query(sql)
        return [f"{r['Staff_ID']} | {r['Surname']} {r.get('other_name') or ''} | {r.get('Department')}" for r in rows]

    def list_staff_raw(self):
        sql = "SELECT Staff_ID, Surname, other_name, Department FROM Staff"
        return self.db.query(sql)

    def add_staff(self, s, hashed_password):
        sql = """INSERT INTO Staff
            (Staff_ID, Surname, other_name, login_password, Department)
            VALUES (?, ?, ?, ?, ?)"""
        params = (s.get('Staff_ID'), s.get('Surname'), s.get('other_name'), hashed_password, s.get('Department'))
        self.db.execute(sql, params)

    def authenticate(self, staff_id, hashed_password):
        sql = "SELECT login_password FROM Staff WHERE Staff_ID = ?"
        rows = self.db.query(sql, (staff_id,))
        if not rows:
            return False
        stored = rows[0].get('login_password')
        return stored == hashed_password
