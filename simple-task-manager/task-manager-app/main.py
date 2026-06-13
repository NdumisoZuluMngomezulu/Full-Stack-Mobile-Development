import sqlite3
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()

# Enable CORS so your Flutter app can communicate with the backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

DATABASE = "tasks.db"

# Initialize Database
def init_db():
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                is_completed INTEGER DEFAULT 0
            )
        """)
        conn.commit()

init_db()

# Pydantic Schemas
class TaskCreate(BaseModel):
    title: str

class TaskResponse(BaseModel):
    id: int
    title: str
    is_completed: bool

# API Endpoints
@app.get("/tasks", response_model=list[TaskResponse])
def get_tasks():
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT id, title, is_completed FROM tasks")
        rows = cursor.fetchall()
        return [{"id": r[0], "title": r[1], "is_completed": bool(r[2])} for r in rows]

@app.post("/tasks", response_model=TaskResponse)
def create_task(task: TaskCreate):
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO tasks (title) VALUES (?)", (task.title,))
        conn.commit()
        task_id = cursor.lastrowid
        return {"id": task_id, "title": task.title, "is_completed": False}

@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):
    with sqlite3.connect(DATABASE) as conn:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM tasks WHERE id = ?", (task_id,))
        conn.commit()
        if cursor.rowcount == 0:
            raise HTTPException(status_status=404, detail="Task not found")
        return {"message": "Task deleted successfully"}

# Run the server
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)