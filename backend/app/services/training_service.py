from __future__ import annotations

import math
from datetime import datetime, timezone
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai_proxy import get_coach_client, get_customer_client
from app.core.exceptions import BadRequestError, NotFoundError
from app.models import Customer, Message, TrainingReport, TrainingSession
from app.schemas.common import PaginatedData
from app.schemas.training import (
    ChatMessageResponse,
    ChatResponse,
    HistoryItem,
    SessionResponse,
    StatisticsResponse,
)


class TrainingService:

    async def get_customers(self, db: AsyncSession) -> list[Customer]:
        result = await db.execute(
            select(Customer).where(Customer.is_active == True).order_by(Customer.id)
        )
        return list(result.scalars().all())

    async def get_customer(self, customer_id: str, db: AsyncSession) -> Customer:
        result = await db.execute(select(Customer).where(Customer.id == customer_id))
        customer = result.scalar_one_or_none()
        if not customer:
            raise NotFoundError("客户不存在")
        return customer

    async def create_session(
        self, user_id: str, customer_id: str, db: AsyncSession
    ) -> tuple[SessionResponse, ChatMessageResponse]:
        # Validate customer
        customer = await self.get_customer(customer_id, db)

        session = TrainingSession(
            user_id=user_id,
            customer_id=customer_id,
        )
        db.add(session)
        await db.flush()

        # Get opening message from AI
        client = get_customer_client()
        opening = await client.get_opening(customer_id, str(session.id))

        # Store customer opening message
        msg = Message(
            session_id=session.id,
            role="customer",
            content=opening["reply"],
            emotion=opening.get("emotion"),
        )
        db.add(msg)
        await db.flush()

        return (
            SessionResponse.model_validate(session),
            ChatMessageResponse.model_validate(msg),
        )

    async def send_message(
        self, session_id: str, user_id: str, content: str, db: AsyncSession
    ) -> ChatResponse:
        session = await self._get_active_session(session_id, user_id, db)

        # Store user message
        user_msg = Message(
            session_id=session.id,
            role="user",
            content=content,
        )
        db.add(user_msg)
        await db.flush()

        # Load history for AI context
        history = await self._load_history(session.id, db)

        # Call AI customer service
        client = get_customer_client()
        ai_response = await client.chat(
            customer_id=session.customer_id,
            session_id=str(session.id),
            message=content,
            dialogue_history=history,
        )

        # Store customer reply
        customer_msg = Message(
            session_id=session.id,
            role="customer",
            content=ai_response["reply"],
            emotion=ai_response.get("emotion"),
        )
        db.add(customer_msg)
        await db.flush()

        is_purchased = ai_response.get("is_purchased", False)
        session_ended = False

        # Auto-end if purchased
        if is_purchased:
            await self._end_session(session, "purchased", db)
            session_ended = True

        return ChatResponse(
            user_message=ChatMessageResponse.model_validate(user_msg),
            customer_message=ChatMessageResponse.model_validate(customer_msg),
            is_purchased=is_purchased,
            session_ended=session_ended,
        )

    async def end_session(self, session_id: str, user_id: str, db: AsyncSession):
        session = await self._get_active_session(session_id, user_id, db)
        await self._end_session(session, "manual", db)

    async def get_report(
        self, session_id: str, user_id: str, db: AsyncSession
    ) -> TrainingReport:
        # Verify session belongs to user
        session = await self._get_session(session_id, user_id, db)
        if session.status != "completed":
            raise BadRequestError("训练尚未结束，无法查看报告")

        result = await db.execute(
            select(TrainingReport).where(TrainingReport.session_id == session.id)
        )
        report = result.scalar_one_or_none()
        if not report:
            raise NotFoundError("报告不存在")
        return report

    async def get_history(
        self, user_id: str, page: int, page_size: int, db: AsyncSession
    ) -> PaginatedData[HistoryItem]:
        # Count total
        count_q = (
            select(func.count())
            .select_from(TrainingSession)
            .where(TrainingSession.user_id == user_id)
        )
        total = (await db.execute(count_q)).scalar() or 0

        # Fetch with join for customer info and report score
        q = (
            select(
                TrainingSession.id.label("session_id"),
                Customer.name.label("customer_name"),
                Customer.avatar.label("customer_avatar"),
                Customer.difficulty,
                TrainingReport.overall_score,
                TrainingSession.end_reason,
                TrainingSession.started_at,
                TrainingSession.ended_at,
            )
            .join(Customer, TrainingSession.customer_id == Customer.id)
            .outerjoin(TrainingReport, TrainingSession.id == TrainingReport.session_id)
            .where(TrainingSession.user_id == user_id)
            .order_by(TrainingSession.started_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        result = await db.execute(q)
        items = [HistoryItem.model_validate(row._mapping) for row in result.all()]

        return PaginatedData(
            items=items,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=math.ceil(total / page_size) if total > 0 else 0,
        )

    async def get_statistics(self, user_id: str, db: AsyncSession) -> StatisticsResponse:
        # Total sessions
        total_q = select(func.count()).select_from(TrainingSession).where(
            TrainingSession.user_id == user_id
        )
        total_sessions = (await db.execute(total_q)).scalar() or 0

        # Completed sessions
        completed_q = select(func.count()).select_from(TrainingSession).where(
            TrainingSession.user_id == user_id,
            TrainingSession.status == "completed",
        )
        completed_sessions = (await db.execute(completed_q)).scalar() or 0

        # Score stats
        score_q = (
            select(
                func.avg(TrainingReport.overall_score).label("avg"),
                func.max(TrainingReport.overall_score).label("max"),
            )
            .join(TrainingSession, TrainingReport.session_id == TrainingSession.id)
            .where(TrainingSession.user_id == user_id)
        )
        score_result = (await db.execute(score_q)).one_or_none()

        # Recent scores
        recent_q = (
            select(TrainingReport.overall_score)
            .join(TrainingSession, TrainingReport.session_id == TrainingSession.id)
            .where(TrainingSession.user_id == user_id)
            .order_by(TrainingReport.created_at.desc())
            .limit(10)
        )
        recent_scores = [r[0] for r in (await db.execute(recent_q)).all()]

        return StatisticsResponse(
            total_sessions=total_sessions,
            completed_sessions=completed_sessions,
            average_score=round(score_result.avg, 1) if score_result and score_result.avg else None,
            highest_score=score_result.max if score_result else None,
            recent_scores=recent_scores,
        )

    # ── Private helpers ──

    async def _get_active_session(
        self, session_id: str, user_id: str, db: AsyncSession
    ) -> TrainingSession:
        result = await db.execute(
            select(TrainingSession).where(
                TrainingSession.id == session_id,
                TrainingSession.user_id == user_id,
            )
        )
        session = result.scalar_one_or_none()
        if not session:
            raise NotFoundError("训练会话不存在")
        if session.status != "active":
            raise BadRequestError("训练会话已结束")
        return session

    async def _get_session(
        self, session_id: str, user_id: str, db: AsyncSession
    ) -> TrainingSession:
        result = await db.execute(
            select(TrainingSession).where(
                TrainingSession.id == session_id,
                TrainingSession.user_id == user_id,
            )
        )
        session = result.scalar_one_or_none()
        if not session:
            raise NotFoundError("训练会话不存在")
        return session

    async def _end_session(self, session: TrainingSession, end_reason: str, db: AsyncSession):
        session.status = "completed"
        session.end_reason = end_reason
        session.ended_at = datetime.now(timezone.utc)
        await db.flush()

        # Generate report
        await self._generate_report(session, db)

    async def _generate_report(self, session: TrainingSession, db: AsyncSession):
        # Load dialogue
        q = (
            select(Message)
            .where(Message.session_id == session.id)
            .order_by(Message.created_at)
        )
        result = await db.execute(q)
        messages = list(result.scalars().all())

        dialogue = [
            {
                "role": msg.role,
                "content": msg.content,
                "timestamp": msg.created_at.isoformat() if msg.created_at else "",
            }
            for msg in messages
        ]

        # Call AI coach service
        client = get_coach_client()
        evaluation = await client.evaluate(
            session_id=str(session.id),
            customer_id=session.customer_id,
            dialogue=dialogue,
            end_reason=session.end_reason or "manual",
        )

        # Convert dimensions list to scores dict keyed by name_cn
        dimensions = evaluation.get("dimensions", [])
        scores = {
            d["name_cn"]: {"score": d["score"], "comment": d["comment"]}
            for d in dimensions
        }

        report = TrainingReport(
            session_id=session.id,
            overall_score=evaluation["overall_score"],
            scores=scores,
            highlights=evaluation.get("highlights", []),
            improvements=evaluation.get("improvements", []),
            annotations=evaluation.get("dialogue_annotations", []),
        )
        db.add(report)
        await db.flush()

    async def _load_history(self, session_id: str, db: AsyncSession) -> list[dict]:
        q = (
            select(Message)
            .where(Message.session_id == session_id)
            .order_by(Message.created_at)
        )
        result = await db.execute(q)
        return [
            {"role": msg.role, "content": msg.content}
            for msg in result.scalars().all()
        ]


training_service = TrainingService()
