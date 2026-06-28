from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routers.search import router as search_router

app = FastAPI(
    title="Bible Verse + Sermon Finder API",
    description="Searches Bible verses and suggests related sermons on YouTube.",
    version="1.0.0",
)

# Wide open for local dev / a mobile app calling from any origin.
# Tighten this if you ever expose the API publicly.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/api/health")
def health() -> dict:
    return {"status": "ok"}


app.include_router(search_router, prefix="/api")
