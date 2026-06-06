from datetime import datetime
from uuid import uuid4

from sqlalchemy import (
    CheckConstraint,
    DateTime,
    ForeignKey,
    Index,
    JSON,
    String,
    Text,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base


class Message(Base):
    __tablename__ = "messages"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid4())
    )
    session_id: Mapped[str] = mapped_column(
        String(36),
        ForeignKey("training_sessions.id", ondelete="CASCADE"),
        nullable=False,
    )
    role: Mapped[str] = mapped_column(String(20), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    emotion: Mapped[str | None] = mapped_column(String(50), nullable=True)
    metadata_: Mapped[dict] = mapped_column(
        "metadata", JSON, nullable=False, default=dict
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    session: Mapped["TrainingSession"] = relationship(
        "TrainingSession", back_populates="messages"
    )

    __table_args__ = (
        CheckConstraint(
            "role IN ('user', 'customer')",
            name="ck_message_role",
        ),
        Index("ix_messages_session_id", "session_id"),
        Index("ix_messages_session_id_created_at", "session_id", "created_at"),
    )

    def __repr__(self) -> str:
        return f"<Message(id={self.id!r}, role={self.role!r})>"
