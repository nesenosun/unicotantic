import sqlite3, datetime
from langchain_groq import ChatGroq
from langchain_core.messages import HumanMessage

RAW_DB = "memory/raw_logs.db"
SEM_DB = "memory/semantic.db"

llm = ChatGroq(model="openai/gpt-oss-120b")

raw = sqlite3.connect(RAW_DB)
sem = sqlite3.connect(SEM_DB)

rc = raw.cursor()
sc = sem.cursor()

today = str(datetime.date.today())

rc.execute("SELECT user, ai FROM logs WHERE time LIKE ?", (today+"%",))
rows = rc.fetchall()

text = ""
for u,a in rows:
    text += f"Kullanıcı: {u}\nUnica: {a}\n"

prompt = f"""
Bugünkü konuşmaları özetle.
Kullanıcı hakkında kalıcı bilgiler çıkar.
Projeler, hedefler, kişilik özellikleri belirt.
"""

response = llm.invoke([HumanMessage(content=prompt + text)])
summary = response.content

sc.execute("INSERT INTO daily_summary VALUES (?,?)", (today, summary))
sem.commit()
