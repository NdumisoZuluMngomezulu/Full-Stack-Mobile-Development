from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, String, Text

from app.database import Base


class SavedQuery(Base):
    """
    One row per search the user has run. results_json stores a full
    snapshot of the verses + sermons returned at the time of the search,
    so re-opening a saved query from history doesn't need to call the
    Bible or YouTube APIs again (faster, and saves YouTube quota).
    """

    __tablename__ = "saved_queries"

    id = Column(Integer, primary_key=True, index=True)
    query_text = Column(String(500), nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    results_json = Column(Text, nullable=False)
