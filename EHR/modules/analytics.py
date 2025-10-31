# modules/analytics.py
from db.database import Database
import csv

class AnalyticsModel:
    def __init__(self, db_config):
        self.db = Database(db_config)

    def monthly_vl(self):
        sql = "SELECT Month, Total_Tested, Suppressed, Percent_Suppressed FROM vw_Monthly_VL_Suppression"
        return self.db.query(sql)

    def new_patients_by_month(self):
        sql = "SELECT Month, Total_New_Patients FROM vw_Monthly_New_Patients"
        return self.db.query(sql)

    def gender_distribution(self):
        sql = "SELECT Gender, COUNT(*) AS Total FROM Patient_Records GROUP BY Gender"
        return self.db.query(sql)

    def monthly_vl_for_plot(self):
        # Returns two lists: months and percent_suppressed (floats) for plotting
        rows = self.monthly_vl()
        months = [r['Month'] for r in rows]
        perc = [float(r['Percent_Suppressed']) for r in rows]
        return months, perc

    def export_to_csv(self, view_sql, path):
        rows = self.db.query(view_sql)
        if not rows:
            return False
        with open(path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(rows[0].keys())
            for r in rows:
                writer.writerow([r[k] for k in rows[0].keys()])
        return True
