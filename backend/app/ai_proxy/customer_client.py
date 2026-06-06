from __future__ import annotations

from app.ai_proxy.base import AIServiceClient
from app.config import settings


class CustomerClient(AIServiceClient):
    """Real simulated customer dialog service client"""

    def __init__(self):
        super().__init__(base_url=settings.AI_SERVICE_BASE_URL)

    async def get_opening(self, customer_id: str, session_id: str) -> dict:
        return await self.post(
            "/customer/opening",
            {
                "customer_id": customer_id,
                "session_id": session_id,
            },
        )

    async def chat(
        self,
        customer_id: str,
        session_id: str,
        message: str,
        dialogue_history: list[dict] | None = None,
    ) -> dict:
        return await self.post(
            "/customer/chat",
            {
                "customer_id": customer_id,
                "session_id": session_id,
                "message": message,
                "dialogue_history": dialogue_history or [],
            },
        )
