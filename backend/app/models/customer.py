from datetime import datetime

from sqlalchemy import JSON, Boolean, CheckConstraint, DateTime, String, func
from sqlalchemy.orm import Mapped, mapped_column

from app.models.base import Base


class Customer(Base):
    __tablename__ = "customers"

    id: Mapped[str] = mapped_column(String(50), primary_key=True)
    name: Mapped[str] = mapped_column(String(50), nullable=False)
    avatar: Mapped[str | None] = mapped_column(String(500), nullable=True)
    difficulty: Mapped[str] = mapped_column(
        String(20), nullable=False, default="中等"
    )
    persona: Mapped[dict] = mapped_column(JSON, nullable=False)
    scenario: Mapped[dict] = mapped_column(JSON, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    __table_args__ = (
        CheckConstraint(
            "difficulty IN ('简单', '中等', '困难')",
            name="ck_customer_difficulty",
        ),
    )

    def __repr__(self) -> str:
        return f"<Customer(id={self.id!r}, name={self.name!r})>"
