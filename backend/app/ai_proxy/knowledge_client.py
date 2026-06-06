from __future__ import annotations

from app.ai_proxy.base import AIServiceClient
from app.config import settings


class KnowledgeClient(AIServiceClient):
    """Real knowledge base Q&A service client"""

    def __init__(self):
        super().__init__(base_url=settings.AI_SERVICE_BASE_URL)

    async def chat(
        self,
        conversation_id: str,
        question: str,
        history: list[dict] | None = None,
    ) -> dict:
        return await self.post(
            "/knowledge/chat",
            {
                "conversation_id": conversation_id,
                "question": question,
                "history": history or [],
            },
        )
