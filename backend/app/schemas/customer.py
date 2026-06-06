from __future__ import annotations

from pydantic import BaseModel


class CustomerPersona(BaseModel):
    age_range: str | None = None
    child_age: str | None = None
    occupation: str | None = None
    personality: str | None = None
    pain_points: list[str] = []
    budget: str | None = None
    decision_style: str | None = None
    initial_attitude: str | None = None
    concerns: list[str] = []


class CustomerScenario(BaseModel):
    context: str | None = None
    product_interest: str | None = None
    success_trigger: str | None = None


class CustomerResponse(BaseModel):
    id: str
    name: str
    avatar: str | None
    difficulty: str
    persona: CustomerPersona | None = None
    scenario: CustomerScenario | None = None
    is_active: bool

    model_config = {"from_attributes": True}


class CustomerListItem(BaseModel):
    """Simplified customer info for list display"""
    id: str
    name: str
    avatar: str | None
    difficulty: str
    description: str | None = None

    model_config = {"from_attributes": True}
