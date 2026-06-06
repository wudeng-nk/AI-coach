from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BadRequestError, UnauthorizedError
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.config import settings
from app.models.user import User
from app.schemas.auth import TokenResponse


class AuthService:

    async def register(self, phone: str, password: str, name: str, db: AsyncSession) -> User:
        # Check phone uniqueness
        result = await db.execute(select(User).where(User.phone == phone))
        if result.scalar_one_or_none():
            raise BadRequestError("该手机号已注册")

        user = User(
            phone=phone,
            password_hash=hash_password(password),
            name=name,
        )
        db.add(user)
        await db.flush()
        return user

    async def login(self, phone: str, password: str, db: AsyncSession) -> tuple[TokenResponse, User]:
        result = await db.execute(select(User).where(User.phone == phone))
        user = result.scalar_one_or_none()

        if not user or not verify_password(password, user.password_hash):
            raise UnauthorizedError("手机号或密码错误")
        if not user.is_active:
            raise UnauthorizedError("账号已被禁用")

        # Update last login
        user.last_login_at = datetime.now(timezone.utc)

        token = TokenResponse(
            access_token=create_access_token(str(user.id), user.role),
            refresh_token=create_refresh_token(str(user.id)),
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )
        return token, user

    async def refresh_token(self, refresh_token: str, db: AsyncSession) -> TokenResponse:
        try:
            payload = decode_token(refresh_token)
            if payload.get("type") != "refresh":
                raise UnauthorizedError("无效的 Token 类型")
            user_id = payload.get("sub")
        except Exception:
            raise UnauthorizedError("Refresh Token 无效或已过期")

        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if not user or not user.is_active:
            raise UnauthorizedError("用户不存在或已禁用")

        return TokenResponse(
            access_token=create_access_token(str(user.id), user.role),
            refresh_token=create_refresh_token(str(user.id)),
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        )

    async def reset_password(self, phone: str, new_password: str, db: AsyncSession):
        result = await db.execute(select(User).where(User.phone == phone))
        user = result.scalar_one_or_none()
        if not user:
            raise BadRequestError("该手机号未注册")
        user.password_hash = hash_password(new_password)


auth_service = AuthService()
