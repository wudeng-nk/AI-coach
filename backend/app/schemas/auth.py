from __future__ import annotations

from pydantic import BaseModel, Field


class RegisterRequest(BaseModel):
    phone: str = Field(..., pattern=r"^1[3-9]\d{9}$", description="手机号")
    password: str = Field(..., min_length=6, max_length=50, description="密码")
    name: str = Field(..., min_length=1, max_length=50, description="姓名")


class LoginRequest(BaseModel):
    phone: str = Field(..., description="手机号")
    password: str = Field(..., description="密码")


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class LoginResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: "UserBriefResponse"


class UserBriefResponse(BaseModel):
    id: str
    phone: str
    name: str
    avatar: str | None
    role: str

    model_config = {"from_attributes": True}


class RefreshRequest(BaseModel):
    refresh_token: str


class PasswordResetRequest(BaseModel):
    phone: str = Field(..., pattern=r"^1[3-9]\d{9}$")
    new_password: str = Field(..., min_length=6, max_length=50)
