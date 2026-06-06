from __future__ import annotations

import math
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.ai_proxy import get_knowledge_client
from app.models.knowledge_chat import KnowledgeChat
from app.schemas.common import PaginatedData
from app.schemas.knowledge import ChatResponse, HistoryItem


class KnowledgeService:

    async def chat(
        self,
        user_id: str,
        question: str,
        conversation_id: UUID | None,
        db: AsyncSession,
    ) -> ChatResponse:
        conv_id = conversation_id or uuid4()

        # Load history for context
        history = await self._load_history(user_id, conv_id, db)

        # Call AI service
        client = get_knowledge_client()
        ai_response = await client.chat(
            conversation_id=str(conv_id),
            question=question,
            history=history,
        )

        # Store record
        record = KnowledgeChat(
            user_id=user_id,
            conversation_id=conv_id,
            question=question,
            answer=ai_response["answer"],
            sources=ai_response.get("sources", []),
            category=ai_response.get("category"),
        )
        db.add(record)
        await db.flush()

        return ChatResponse(
            conversation_id=str(conv_id),
            answer=ai_response["answer"],
            sources=ai_response.get("sources", []),
            category=ai_response.get("category"),
            suggestions=ai_response.get("suggestions", []),
        )

    async def get_history(
        self,
        user_id: str,
        page: int,
        page_size: int,
        db: AsyncSession,
    ) -> PaginatedData[HistoryItem]:
        # Count total
        count_q = select(func.count()).select_from(KnowledgeChat).where(
            KnowledgeChat.user_id == user_id
        )
        total = (await db.execute(count_q)).scalar() or 0

        # Fetch page
        q = (
            select(KnowledgeChat)
            .where(KnowledgeChat.user_id == user_id)
            .order_by(KnowledgeChat.created_at.desc())
            .offset((page - 1) * page_size)
            .limit(page_size)
        )
        result = await db.execute(q)
        items = [HistoryItem.model_validate(r) for r in result.scalars().all()]

        return PaginatedData(
            items=items,
            total=total,
            page=page,
            page_size=page_size,
            total_pages=math.ceil(total / page_size) if total > 0 else 0,
        )

    async def submit_feedback(self, chat_id: str, feedback: str, user_id: str, db: AsyncSession):
        result = await db.execute(
            select(KnowledgeChat).where(
                KnowledgeChat.id == chat_id,
                KnowledgeChat.user_id == user_id,
            )
        )
        record = result.scalar_one_or_none()
        if not record:
            from app.core.exceptions import NotFoundError
            raise NotFoundError("对话记录不存在")
        record.feedback = feedback
        await db.flush()

    async def _load_history(
        self, user_id: str, conversation_id: UUID, db: AsyncSession, limit: int = 10
    ) -> list[dict]:
        q = (
            select(KnowledgeChat)
            .where(
                KnowledgeChat.user_id == user_id,
                KnowledgeChat.conversation_id == conversation_id,
            )
            .order_by(KnowledgeChat.created_at.desc())
            .limit(limit)
        )
        result = await db.execute(q)
        history = []
        for record in reversed(result.scalars().all()):
            history.append({"role": "user", "content": record.question})
            history.append({"role": "assistant", "content": record.answer})
        return history


knowledge_service = KnowledgeService()
