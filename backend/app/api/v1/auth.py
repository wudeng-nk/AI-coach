from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.schemas.auth import LoginRequest, LoginResponse, PasswordResetRequest, RefreshRequest, RegisterRequest, TokenResponse
from app.schemas.common import ApiResponse
from app.schemas.user import UserResponse
from app.services.auth_service import auth_service

router = APIRouter()


@router.post("/register", response_model=ApiResponse[UserResponse])
async def register(body: RegisterRequest, db: AsyncSession = Depends(get_db)):
    user = await auth_service.register(body.phone, body.password, body.name, db)
    return ApiResponse(data=UserResponse.model_validate(user))


@router.post("/login", response_model=ApiResponse[LoginResponse])
async def login(body: LoginRequest, db: AsyncSession = Depends(get_db)):
    token, user = await auth_service.login(body.phone, body.password, db)
    from app.schemas.auth import UserBriefResponse
    return ApiResponse(data=LoginResponse(
        access_token=token.access_token,
        refresh_token=token.refresh_token,
        token_type=token.token_type,
        expires_in=token.expires_in,
        user=UserBriefResponse(
            id=str(user.id),
            phone=user.phone,
            name=user.name,
            avatar=user.avatar,
            role=user.role.value,
        ),
    ))


@router.post("/refresh", response_model=ApiResponse[TokenResponse])
async def refresh_token(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    token = await auth_service.refresh_token(body.refresh_token, db)
    return ApiResponse(data=token)


@router.post("/password/reset", response_model=ApiResponse)
async def reset_password(body: PasswordResetRequest, db: AsyncSession = Depends(get_db)):
    await auth_service.reset_password(body.phone, body.new_password, db)
    return ApiResponse(message="密码重置成功")
