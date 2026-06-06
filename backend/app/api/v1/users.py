from __future__ import annotations

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.user import User
from app.schemas.common import ApiResponse
from app.schemas.user import PasswordChangeRequest, UserResponse, UserUpdateRequest
from app.services.user_service import user_service

router = APIRouter()


@router.get("/me", response_model=ApiResponse[UserResponse])
async def get_profile(current_user: User = Depends(get_current_user)):
    return ApiResponse(data=UserResponse.model_validate(current_user))


@router.put("/me", response_model=ApiResponse[UserResponse])
async def update_profile(
    body: UserUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    user = await user_service.update_profile(current_user, body, db)
    return ApiResponse(data=UserResponse.model_validate(user))


@router.put("/me/password", response_model=ApiResponse)
async def change_password(
    body: PasswordChangeRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await user_service.change_password(
        current_user, body.old_password, body.new_password, db
    )
    return ApiResponse(message="密码修改成功")
