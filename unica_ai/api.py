from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import main
import datetime
import sqlite3

app = FastAPI(title="Unica API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str

class ChatResponse(BaseModel):
    response: str
    thought: str

@app.get("/history")
async def get_history(limit: int = 5, offset: int = 0):
    conn = sqlite3.connect(main.RAW_DB)
    c = conn.cursor()
    c.execute("SELECT user, ai, time FROM logs ORDER BY time DESC LIMIT ? OFFSET ?", (limit, offset))
    rows = c.fetchall()
    conn.close()
    rows.reverse() # Return in chronological order
    return [{"user": r[0], "ai": r[1], "time": r[2]} for r in rows]

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        # İç düşünce üret
        main.generate_inner_thought(request.message)
        
        # Son düşünceyi çek
        sc = sqlite3.connect(main.SEM_DB).cursor()
        sc.execute("SELECT thought FROM inner_thoughts ORDER BY time DESC LIMIT 1")
        thought = sc.fetchone()[0]
        
        # Yanıt üret
        # main.py'deki chat döngüsünü taklit ediyoruz
        main.rc.execute("SELECT user,ai FROM logs ORDER BY time DESC LIMIT 6")
        past = main.rc.fetchall()
        history = []
        for u,a in past:
            history.append(main.HumanMessage(content=u))
            history.append(main.SystemMessage(content=a))
        
        history.append(main.HumanMessage(content=request.message))
        history = history[-main.MAX_HISTORY:]
        messages = [main.SystemMessage(content=main.build_system())] + history
        
        response = main.llm.invoke(messages)
        ai_text = response.content.strip() if response.content else "..."
        
        # Kaydet
        main.rc.execute("INSERT INTO logs VALUES (?,?,?)",
                       (str(datetime.datetime.now()), request.message, ai_text))
        main.raw.commit()
        
        return ChatResponse(response=ai_text, thought=thought)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
