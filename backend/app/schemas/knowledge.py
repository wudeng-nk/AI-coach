from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class ChatRequest(BaseModel):
    question: str = Field(..., min_length=1, max_length=2000)
    conversation_id: UUID | None = Field(None, description="会话ID，不传则创建新会话")


class ChatResponse(BaseModel):
    conversation_id: str
    answer: str
    sources: list[str] = []
    category: str | None = None
    suggestions: list[str] = []


class HistoryItem(BaseModel):
    id: str
    conversation_id: str
    question: str
    answer: str
    sources: list[str] = []
    category: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class FeedbackRequest(BaseModel):
    chat_id: str = Field(..., description="知识库对话记录ID")
    feedback: str = Field(..., pattern=r"^(helpful|unhelpful)$")
