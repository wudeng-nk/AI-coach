from __future__ import annotations

from app.ai_proxy.base import AIServiceClient
from app.config import settings


class CoachClient(AIServiceClient):
    """Real coach evaluation service client"""

    def __init__(self):
        super().__init__(base_url=settings.AI_SERVICE_BASE_URL)

    async def evaluate(
        self,
        session_id: str,
        customer_id: str,
        dialogue: list[dict],
        end_reason: str,
    ) -> dict:
        return await self.post(
            "/coach/evaluate",
            {
                "session_id": session_id,
                "customer_id": customer_id,
                "dialogue": dialogue,
                "end_reason": end_reason,
            },
        )
