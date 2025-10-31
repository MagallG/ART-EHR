# HospitalApp (Kivy front-end)

This version adds:
- Background threads for DB operations using threading + kivy.clock
- CSV export helper for analytics
- Placeholder hooks to render matplotlib charts (you'll need to embed images or use kivy.garden.matplotlib)
- Optional simple Flask API (flask_api.py) if you'd rather run an API backend and point the UI to it.

Run the app:
1. Install dependencies:
   pip install -r requirements.txt
2. Edit DB config in hospital_app.py
3. Run (for GUI):
   python hospital_app.py
4. Run API (optional):
   python flask_api.py
