from __future__ import annotations

from typing import Annotated
from uuid import UUID

from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.exceptions import ForbiddenError, UnauthorizedError
from app.core.security import decode_token
from app.models.user import User, UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(oauth2_scheme),
) -> User:
    """Dependency: extract and validate current user from Bearer token."""
    try:
        payload = decode_token(token)
        if payload.get("type") != "access":
            raise UnauthorizedError("无效的 Token 类型")
        user_id = payload.get("sub")
        if user_id is None:
            raise UnauthorizedError("Token 缺少用户标识")
    except JWTError:
        raise UnauthorizedError("Token 无效或已过期")

    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user is None or not user.is_active:
        raise UnauthorizedError("用户不存在或已禁用")
    return user


def require_role(*roles: UserRole):
    """Dependency factory: require specific roles."""
    async def role_checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in roles:
            raise ForbiddenError()
        return current_user
    return role_checker
