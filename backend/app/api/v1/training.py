from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.schemas.common import ApiResponse, PaginatedResponse
from app.schemas.customer import CustomerListItem, CustomerResponse
from app.schemas.report import ReportResponse
from app.schemas.training import (
    ChatMessageRequest,
    ChatResponse,
    HistoryItem,
    SessionCreateRequest,
    SessionEndRequest,
    SessionResponse,
    StatisticsResponse,
)
from app.services.training_service import training_service

router = APIRouter()


# ── Customers ──

@router.get("/customers", response_model=ApiResponse[list[CustomerListItem]])
async def list_customers(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    customers = await training_service.get_customers(db)
    items = [
        CustomerListItem(
            id=c.id,
            name=c.name,
            avatar=c.avatar,
            difficulty=c.difficulty,
            description=c.persona.get("personality", "") if isinstance(c.persona, dict) else "",
        )
        for c in customers
    ]
    return ApiResponse(data=items)


@router.get("/customers/{customer_id}", response_model=ApiResponse[CustomerResponse])
async def get_customer(
    customer_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    customer = await training_service.get_customer(customer_id, db)
    return ApiResponse(data=CustomerResponse.model_validate(customer))


# ── Sessions ──

@router.post("/sessions", response_model=ApiResponse)
async def create_session(
    body: SessionCreateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session, opening_msg = await training_service.create_session(
        user_id=current_user.id,
        customer_id=body.customer_id,
        db=db,
    )
    return ApiResponse(
        data={
            "session": SessionResponse.model_validate(session).model_dump(),
            "opening_message": {
                "id": opening_msg.id,
                "role": opening_msg.role,
                "content": opening_msg.content,
                "emotion": opening_msg.emotion,
            },
        }
    )


@router.post("/sessions/{session_id}/chat", response_model=ApiResponse[ChatResponse])
async def send_message(
    session_id: str,
    body: ChatMessageRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await training_service.send_message(
        session_id=session_id,
        user_id=current_user.id,
        content=body.content,
        db=db,
    )
    return ApiResponse(data=result)


@router.post("/sessions/{session_id}/end", response_model=ApiResponse)
async def end_session(
    session_id: str,
    body: SessionEndRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await training_service.end_session(session_id, current_user.id, db)
    return ApiResponse(message="训练已结束，评分报告生成中")


# ── Reports ──

@router.get("/sessions/{session_id}/report", response_model=ApiResponse[ReportResponse])
async def get_report(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    report = await training_service.get_report(session_id, current_user.id, db)
    return ApiResponse(data=ReportResponse.model_validate(report))


# ── History & Statistics ──

@router.get("/history", response_model=PaginatedResponse[HistoryItem])
async def get_history(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    data = await training_service.get_history(current_user.id, page, page_size, db)
    return PaginatedResponse(data=data)


@router.get("/statistics", response_model=ApiResponse[StatisticsResponse])
async def get_statistics(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stats = await training_service.get_statistics(current_user.id, db)
    return ApiResponse(data=stats)
