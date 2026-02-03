import sqlite3, datetime

SEM_DB = "memory/semantic.db"
conn = sqlite3.connect(SEM_DB)
c = conn.cursor()

c.execute("CREATE TABLE IF NOT EXISTS user_profile (key TEXT, value TEXT, updated_at TEXT)")
c.execute("CREATE TABLE IF NOT EXISTS daily_summary (date TEXT, summary TEXT)")
c.execute("CREATE TABLE IF NOT EXISTS weekly_summary (week TEXT, summary TEXT)")
conn.commit()

def get_user_profile():
    c.execute("SELECT key, value FROM user_profile")
    rows = c.fetchall()
    return "\n".join([f"{k}: {v}" for k,v in rows])

def get_latest_daily():
    c.execute("SELECT summary FROM daily_summary ORDER BY date DESC LIMIT 1")
    row = c.fetchone()
    return row[0] if row else "Henüz özet yok."

def update_profile(key, value):
    now = str(datetime.datetime.now())
    c.execute("DELETE FROM user_profile WHERE key=?", (key,))
    c.execute("INSERT INTO user_profile VALUES (?,?,?)", (key,value,now))
    conn.commit()
