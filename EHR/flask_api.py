# flask_api.py
from flask import Flask, jsonify, request
from db.database import Database
app = Flask(__name__)
db = Database({'server': r'localhost\\SQLEXPRESS', 'database': 'ART_ehr'})

@app.route('/patients', methods=['GET'])
def patients():
    rows = db.query("SELECT Patient_ID, Sur_name, Other_name FROM Patient_Records")
    return jsonify(rows)

@app.route('/patient/<pid>', methods=['GET'])
def get_patient(pid):
    rows = db.query("SELECT * FROM Patient_Records WHERE Patient_ID = ?", (pid,))
    return jsonify(rows[0] if rows else {})

@app.route('/export/monthly_vl', methods=['GET'])
def export_monthly_vl():
    rows = db.query("SELECT Month, Total_Tested, Suppressed, Percent_Suppressed FROM vw_Monthly_VL_Suppression")
    return jsonify(rows)

if __name__ == '__main__':
    app.run(debug=True, port=5000)
