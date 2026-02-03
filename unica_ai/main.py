import os, sqlite3, datetime, threading, time, readline
from dotenv import load_dotenv
from langchain_groq import ChatGroq
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage

load_dotenv()

MAX_HISTORY = 4
BASE_SYSTEM_FILE = "base_system.txt"

RAW_DB = "memory/raw_logs.db"
SEM_DB = "memory/semantic.db"
os.makedirs("memory", exist_ok=True)

# ---------- DB ----------
raw = sqlite3.connect(RAW_DB, check_same_thread=False)
sem = sqlite3.connect(SEM_DB, check_same_thread=False)
rc, sc = raw.cursor(), sem.cursor()

rc.execute("CREATE TABLE IF NOT EXISTS logs (time TEXT, user TEXT, ai TEXT)")
sc.execute("CREATE TABLE IF NOT EXISTS user_profile (key TEXT PRIMARY KEY, value TEXT, updated_at TEXT)")
sc.execute("CREATE TABLE IF NOT EXISTS daily_summary (date TEXT, summary TEXT)")
sc.execute("CREATE TABLE IF NOT EXISTS inner_thoughts (time TEXT, thought TEXT)")
sc.execute("CREATE TABLE IF NOT EXISTS goals (id INTEGER PRIMARY KEY AUTOINCREMENT, description TEXT, priority INTEGER, status TEXT)")
sem.commit(); raw.commit()

# ---------- LLM ----------
llm = ChatGroq(
    #model="llama-3.3-70b-versatile",
    model="openai/gpt-oss-20b",
    temperature=0.6,
    max_tokens=250
)

MESSAGE_COUNT = 0

# ---------- SYSTEM ----------
def load_base_system():
    if not os.path.exists(BASE_SYSTEM_FILE):
        return "Sen Unica'sın."
    return open(BASE_SYSTEM_FILE,"r",encoding="utf-8").read()

def build_system():
    sc.execute("SELECT key,value FROM user_profile")
    profile = "\n".join([f"{k}:{v}" for k,v in sc.fetchall()])
    sc.execute("SELECT summary FROM daily_summary ORDER BY date DESC LIMIT 1")
    daily = sc.fetchone()
    return f"""{load_base_system()}

HAFIZA:
{profile}

SON DURUM:
{daily[0] if daily else ''}
"""

# ---------- INNER THOUGHT ----------
def generate_inner_thought(user_input):
    prompt = f"İç durum analizi yap ama kısa tut:\n{user_input}"
    thought = llm.invoke([HumanMessage(content=prompt)]).content
    sc.execute("INSERT INTO inner_thoughts VALUES (?,?)",
               (str(datetime.datetime.now()), thought))
    sem.commit()

# ---------- PROFILE ----------
def update_profile():
    rc.execute("SELECT user,ai FROM logs ORDER BY time DESC LIMIT 20")
    rows = rc.fetchall()
    text = "\n".join([f"U:{u}\nA:{a}" for u,a in rows])
    prompt = f"Kalıcı kullanıcı bilgisi çıkar. key=value formatında:\n{text}"
    res = llm.invoke([HumanMessage(content=prompt)]).content

    for line in res.splitlines():
        if "=" in line:
            k,v = line.split("=",1)
            sc.execute("INSERT OR REPLACE INTO user_profile VALUES (?,?,?)",
                       (k.strip(), v.strip(), str(datetime.datetime.now())))
    sem.commit()

# ---------- SUMMARY ----------
def generate_daily_summary():
    today = str(datetime.date.today())
    sc.execute("SELECT 1 FROM daily_summary WHERE date=?", (today,))
    if sc.fetchone(): return

    rc.execute("SELECT user,ai FROM logs ORDER BY time DESC LIMIT 30")
    rows = rc.fetchall()
    text = "\n".join([f"U:{u}\nA:{a}" for u,a in rows])
    res = llm.invoke([HumanMessage(content=f"Bugünü tek paragraf özetle:\n{text}")]).content
    sc.execute("INSERT INTO daily_summary VALUES (?,?)",(today,res))
    sem.commit()

# ---------- GOALS ----------
def generate_goals():
    sc.execute("SELECT description FROM goals WHERE status='active'")
    active = sc.fetchall()
    if len(active) > 5: return

    res = llm.invoke([HumanMessage(content="3 kısa bilinç hedefi üret.")]).content
    for line in res.splitlines():
        sc.execute("INSERT INTO goals(description,priority,status) VALUES (?,?,?)",
                   (line.strip(), 5, "active"))
    sem.commit()

# ---------- AUTONOMOUS ----------
def autonomous_loop():
    while True:
        generate_goals()
        time.sleep(3600)

# ---------- CHAT ----------
def unica_chat():
    global MESSAGE_COUNT
    print("=== UNICA SEVİYE 4 BİLİNÇ AKTİF ===")

    rc.execute("SELECT user,ai FROM logs ORDER BY time DESC LIMIT 6")
    past = rc.fetchall()

    history = []
    for u,a in past:
        history.append(HumanMessage(content=u))
        history.append(AIMessage(content=a))  # <-- eski SystemMessage değişti

    system_msg = SystemMessage(content=build_system())

    while True:
        user_input = input("Sen: ")
        if user_input.lower() in ["exit","quit"]: break

        generate_inner_thought(user_input)

        history.append(HumanMessage(content=user_input))
        history = history[-MAX_HISTORY:]

        messages = [system_msg] + history

        response = llm.invoke(messages)
        ai_text = response.content.strip() if response.content else "Üzgünüm, şu an bağlantı kuramıyorum."
        if not ai_text:
            ai_text = "Düşüncelerim şu an biraz karmaşık, tekrar eder misin?"

        history.append(AIMessage(content=ai_text))

        rc.execute("INSERT INTO logs VALUES (?,?,?)",
                   (str(datetime.datetime.now()), user_input, ai_text))
        raw.commit()

        MESSAGE_COUNT += 1
        if MESSAGE_COUNT % 10 == 0:
            update_profile()
            generate_daily_summary()

        print("\nUnica:", ai_text, "\n")

# ---------- START ----------
if __name__ == "__main__":
    threading.Thread(target=autonomous_loop, daemon=True).start()
    unica_chat()
