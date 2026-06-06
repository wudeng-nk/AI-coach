from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class ScoreDetail(BaseModel):
    score: int
    comment: str


class DialogueAnnotation(BaseModel):
    message_index: int
    role: str
    content: str
    feedback: str


class ReportResponse(BaseModel):
    id: str
    session_id: str
    overall_score: int
    scores: dict[str, ScoreDetail]
    highlights: list[str]
    improvements: list[str]
    dialogue_annotations: list[DialogueAnnotation] = Field(alias="annotations")
    created_at: datetime

    model_config = {"from_attributes": True, "populate_by_name": True}
