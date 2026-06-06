from __future__ import annotations

from app.config import settings


def get_knowledge_client():
    if settings.is_mock_ai:
        from app.ai_proxy.mock_knowledge_client import MockKnowledgeClient
        return MockKnowledgeClient()
    from app.ai_proxy.knowledge_client import KnowledgeClient
    return KnowledgeClient()


def get_customer_client():
    if settings.is_mock_ai:
        from app.ai_proxy.mock_customer_client import MockCustomerClient
        return MockCustomerClient()
    from app.ai_proxy.customer_client import CustomerClient
    return CustomerClient()


def get_coach_client():
    if settings.is_mock_ai:
        from app.ai_proxy.mock_coach_client import MockCoachClient
        return MockCoachClient()
    from app.ai_proxy.coach_client import CoachClient
    return CoachClient()
