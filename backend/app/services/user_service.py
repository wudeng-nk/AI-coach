from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import BadRequestError
from app.core.security import hash_password, verify_password
from app.models.user import User
from app.schemas.user import UserUpdateRequest


class UserService:

    async def update_profile(self, user: User, data: UserUpdateRequest, db: AsyncSession) -> User:
        if data.name is not None:
            user.name = data.name
        if data.avatar is not None:
            user.avatar = data.avatar
        if data.organization is not None:
            user.organization = data.organization
        await db.flush()
        return user

    async def change_password(self, user: User, old_password: str, new_password: str, db: AsyncSession):
        if not verify_password(old_password, user.password_hash):
            raise BadRequestError("原密码错误")
        user.password_hash = hash_password(new_password)
        await db.flush()


user_service = UserService()
