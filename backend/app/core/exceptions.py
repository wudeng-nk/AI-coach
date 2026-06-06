from __future__ import annotations

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from jose import JWTError


class AppException(Exception):
    def __init__(self, status_code: int, message: str, detail: str = ""):
        self.status_code = status_code
        self.message = message
        self.detail = detail


class NotFoundError(AppException):
    def __init__(self, message: str = "资源不存在"):
        super().__init__(404, message)


class UnauthorizedError(AppException):
    def __init__(self, message: str = "未授权"):
        super().__init__(401, message)


class ForbiddenError(AppException):
    def __init__(self, message: str = "权限不足"):
        super().__init__(403, message)


class BadRequestError(AppException):
    def __init__(self, message: str = "请求参数错误"):
        super().__init__(400, message)


class AIServiceError(AppException):
    def __init__(self, message: str = "AI 服务暂时不可用"):
        super().__init__(502, message)


class AIServiceTimeoutError(AppException):
    def __init__(self, message: str = "AI 服务响应超时"):
        super().__init__(504, message)


def register_exception_handlers(app: FastAPI):
    @app.exception_handler(AppException)
    async def app_exception_handler(request: Request, exc: AppException):
        return JSONResponse(
            status_code=exc.status_code,
            content={"code": exc.status_code, "message": exc.message, "detail": exc.detail},
        )

    @app.exception_handler(JWTError)
    async def jwt_exception_handler(request: Request, exc: JWTError):
        return JSONResponse(
            status_code=401,
            content={"code": 401, "message": "Token 无效或已过期", "detail": str(exc)},
        )
