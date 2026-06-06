from __future__ import annotations

import asyncio

import httpx

from app.config import settings


class AIServiceError(Exception):
    pass


class AIServiceTimeoutError(AIServiceError):
    pass


class AIServiceClient:
    """Base client for external AI services with retry and timeout handling"""

    def __init__(self, base_url: str, timeout: int | None = None):
        self.base_url = base_url
        self.timeout = timeout or settings.AI_SERVICE_TIMEOUT
        self._client: httpx.AsyncClient | None = None

    async def get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                base_url=self.base_url,
                timeout=self.timeout,
                headers={
                    "Authorization": f"Bearer {settings.AI_SERVICE_API_KEY}",
                    "Content-Type": "application/json",
                },
            )
        return self._client

    async def post(self, path: str, json_data: dict, max_retries: int = 3) -> dict:
        """Send POST request with retry logic"""
        client = await self.get_client()
        last_error = None

        for attempt in range(max_retries):
            try:
                response = await client.post(path, json=json_data)
                response.raise_for_status()
                return response.json()
            except httpx.TimeoutException as e:
                last_error = e
                if attempt < max_retries - 1:
                    await asyncio.sleep(0.5 * (attempt + 1))
            except httpx.HTTPStatusError as e:
                raise AIServiceError(f"AI 服务返回错误: {e.response.status_code}")
            except httpx.RequestError as e:
                last_error = e
                if attempt < max_retries - 1:
                    await asyncio.sleep(0.5 * (attempt + 1))

        raise AIServiceTimeoutError("AI 服务响应超时，请稍后重试")

    async def close(self):
        if self._client and not self._client.is_closed:
            await self._client.close()
