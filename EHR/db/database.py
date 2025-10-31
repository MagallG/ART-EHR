# db/database.py
import pyodbc

class Database:
    def __init__(self, config):
        driver = config.get('driver', '{ODBC Driver 17 for SQL Server}')
        server = config['server']
        database = config['database']
        uid = config.get('uid')
        pwd = config.get('pwd')

        if uid and pwd:
            self.conn_str = f"DRIVER={driver};SERVER={server};DATABASE={database};UID={uid};PWD={pwd};"
        else:
            self.conn_str = f"DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;"

    def _get_conn(self):
        return pyodbc.connect(self.conn_str, autocommit=True)

    def query(self, sql, params=()):
        with self._get_conn() as conn:
            cur = conn.cursor()
            cur.execute(sql, params)
            cols = [c[0] for c in cur.description] if cur.description else []
            rows = cur.fetchall()
            return [dict(zip(cols, row)) for row in rows]

    def execute(self, sql, params=()):
        with self._get_conn() as conn:
            cur = conn.cursor()
            cur.execute(sql, params)
