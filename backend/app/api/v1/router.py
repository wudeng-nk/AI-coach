from fastapi import APIRouter

from app.api.v1 import auth, knowledge, training, users

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["认证"])
api_router.include_router(users.router, prefix="/users", tags=["用户"])
api_router.include_router(knowledge.router, prefix="/knowledge", tags=["知识库"])
api_router.include_router(training.router, prefix="/training", tags=["训练"])
