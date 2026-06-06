from datetime import datetime
from uuid import uuid4

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    JSON,
    SmallInteger,
    String,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class TrainingReport(Base):
    __tablename__ = "training_reports"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid4())
    )
    session_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("training_sessions.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
    )
    overall_score: Mapped[int] = mapped_column(SmallInteger, nullable=False)
    scores: Mapped[dict] = mapped_column(JSON, nullable=False)
    highlights: Mapped[dict] = mapped_column(JSON, nullable=False, default=list)
    improvements: Mapped[dict] = mapped_column(JSON, nullable=False, default=list)
    annotations: Mapped[dict] = mapped_column(JSON, nullable=False, default=list)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    __table_args__ = (
        CheckConstraint(
            "overall_score >= 0 AND overall_score <= 100",
            name="ck_training_report_overall_score",
        ),
    )

    def __repr__(self) -> str:
        return f"<TrainingReport(id={self.id!r}, overall_score={self.overall_score!r})>"
