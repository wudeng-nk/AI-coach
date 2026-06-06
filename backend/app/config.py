from __future__ import annotations

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # 应用
    APP_NAME: str = "AI Coach"
    APP_ENV: str = "development"
    DEBUG: bool = True

    # 数据库
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/ai_coach"

    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"

    # JWT
    JWT_SECRET_KEY: str = "change-this-to-a-random-secret-key-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # AI 服务
    AI_SERVICE_MODE: str = "mock"  # mock | real
    AI_SERVICE_BASE_URL: str = "https://ai-service.example.com"
    AI_SERVICE_API_KEY: str = ""
    AI_SERVICE_TIMEOUT: int = 30

    # CORS
    CORS_ORIGINS: list[str] = ["http://localhost:3000", "http://localhost:5000"]

    @property
    def is_mock_ai(self) -> bool:
        return self.AI_SERVICE_MODE == "mock"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
