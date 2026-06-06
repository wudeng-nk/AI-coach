from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class SessionCreateRequest(BaseModel):
    customer_id: str = Field(..., description="模拟客户ID")


class SessionResponse(BaseModel):
    id: str
    customer_id: str
    status: str
    end_reason: str | None = None
    started_at: datetime
    ended_at: datetime | None = None

    model_config = {"from_attributes": True}


class ChatMessageRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class ChatMessageResponse(BaseModel):
    id: str
    role: str
    content: str
    emotion: str | None = None
    created_at: datetime

    model_config = {"from_attributes": True}


class ChatResponse(BaseModel):
    """Response for sending a message during training"""
    user_message: ChatMessageResponse
    customer_message: ChatMessageResponse | None = None
    is_purchased: bool = False
    session_ended: bool = False


class SessionEndRequest(BaseModel):
    pass  # manual end, no extra params needed


class HistoryItem(BaseModel):
    """Training history list item"""
    session_id: str
    customer_name: str
    customer_avatar: str | None
    difficulty: str
    overall_score: int | None = None
    end_reason: str | None = None
    started_at: datetime
    ended_at: datetime | None = None


class StatisticsResponse(BaseModel):
    total_sessions: int
    completed_sessions: int
    average_score: float | None = None
    highest_score: int | None = None
    recent_scores: list[int] = []  # last 10 scores for trend
