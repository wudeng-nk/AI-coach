from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.schemas.common import ApiResponse, PaginatedResponse
from app.schemas.knowledge import ChatRequest, ChatResponse, FeedbackRequest, HistoryItem
from app.services.knowledge_service import knowledge_service

router = APIRouter()


@router.post("/chat", response_model=ApiResponse[ChatResponse])
async def chat(
    body: ChatRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await knowledge_service.chat(
        user_id=current_user.id,
        question=body.question,
        conversation_id=body.conversation_id,
        db=db,
    )
    return ApiResponse(data=result)


@router.get("/history", response_model=PaginatedResponse[HistoryItem])
async def get_history(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await knowledge_service.get_history(current_user.id, page, page_size, db)
    return PaginatedResponse(data=data)


@router.post("/feedback", response_model=ApiResponse)
async def submit_feedback(
    body: FeedbackRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await knowledge_service.submit_feedback(body.chat_id, body.feedback, current_user.id, db)
    return ApiResponse(message="反馈提交成功")
