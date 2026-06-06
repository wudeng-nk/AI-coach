from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field

from app.models.user import UserRole


class UserResponse(BaseModel):
    id: str
    phone: str
    name: str
    avatar: str | None
    role: UserRole
    organization: str | None
    is_active: bool
    last_login_at: datetime | None
    created_at: datetime

    model_config = {"from_attributes": True}


class UserUpdateRequest(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=50)
    avatar: str | None = None
    organization: str | None = Field(None, max_length=100)


class PasswordChangeRequest(BaseModel):
    old_password: str = Field(..., min_length=6)
    new_password: str = Field(..., min_length=6, max_length=50)
