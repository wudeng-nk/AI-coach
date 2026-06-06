"""Seed script: populate initial mock customers.

Usage:
    cd backend && python -m scripts.seed_customers
"""

import asyncio
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import async_session_factory, engine
from app.models.base import Base
from app.models.customer import Customer
from app.models.user import User
from app.core.security import hash_password

CUSTOMERS = [
    {
        "id": "customer_001",
        "name": "张妈妈",
        "avatar": "👩",
        "difficulty": "中等",
        "persona": {
            "age_range": "30-35岁",
            "child_age": "5岁",
            "occupation": "公司白领",
            "personality": "理性谨慎，注重性价比",
            "pain_points": ["孩子注意力不集中", "试过几家机构不满意"],
            "budget": "中等",
            "decision_style": "需要大量信息支撑，对比后才决策",
            "initial_attitude": "观望，不太信任",
            "concerns": ["效果能否保证", "价格是否合理"],
        },
        "scenario": {
            "context": "在商场被地推人员引导加微信后首次沟通",
            "product_interest": "思维训练课程",
            "success_trigger": "明确表达报名意愿或询问具体报名流程",
        },
    },
    {
        "id": "customer_002",
        "name": "李爸爸",
        "avatar": "👨",
        "difficulty": "困难",
        "persona": {
            "age_range": "35-40岁",
            "child_age": "7岁",
            "occupation": "IT 工程师",
            "personality": "逻辑性强，喜欢追问细节，防备心重",
            "pain_points": ["孩子数学成绩不理想", "对传统补习班效果不满意"],
            "budget": "较高",
            "decision_style": "需要数据支撑，会深入研究对比",
            "initial_attitude": "质疑，认为思维训练是噱头",
            "concerns": ["课程科学性", "能否真正提升成绩"],
        },
        "scenario": {
            "context": "朋友推荐后主动添加微信咨询",
            "product_interest": "思维训练课程（进阶班）",
            "success_trigger": "认可课程体系的科学性，主动询问上课安排",
        },
    },
    {
        "id": "customer_003",
        "name": "王妈妈",
        "avatar": "👩‍🦱",
        "difficulty": "简单",
        "persona": {
            "age_range": "28-32岁",
            "child_age": "4岁",
            "occupation": "全职妈妈",
            "personality": "热情开放，容易接受新事物",
            "pain_points": ["孩子内向不善表达", "想找合适的启蒙课程"],
            "budget": "中等",
            "decision_style": "感性决策，注重口碑和体验",
            "initial_attitude": "好奇，有意愿了解",
            "concerns": ["孩子太小能否适应", "上课时间是否灵活"],
        },
        "scenario": {
            "context": "在小区家长群里看到其他家长分享后主动咨询",
            "product_interest": "思维训练课程（启蒙班）",
            "success_trigger": "被体验课吸引，主动询问报名事宜",
        },
    },
    {
        "id": "customer_004",
        "name": "赵妈妈",
        "avatar": "👩‍🦰",
        "difficulty": "困难",
        "persona": {
            "age_range": "33-38岁",
            "child_age": "6岁",
            "occupation": "企业中层管理",
            "personality": "强势果断，效率至上，不喜废话",
            "pain_points": ["孩子依赖性强，缺乏独立思考能力", "之前报过课但中途退费"],
            "budget": "高",
            "decision_style": "快速决策，注重品质和专业度",
            "initial_attitude": "不耐烦，对销售推销反感",
            "concerns": ["不想浪费时间", "课程是否有差异化价值"],
        },
        "scenario": {
            "context": "收到短信营销后回复了'了解一下'",
            "product_interest": "思维训练课程（基础班）",
            "success_trigger": "认可课程的专业度，直接问价格和排课",
        },
    },
    {
        "id": "customer_005",
        "name": "陈妈妈",
        "avatar": "👱‍♀️",
        "difficulty": "中等",
        "persona": {
            "age_range": "30-35岁",
            "child_age": "8岁",
            "occupation": "教师",
            "personality": "温和有耐心，重视教育理念和方法论",
            "pain_points": ["孩子创新思维不足", "学校教育偏应试"],
            "budget": "中等",
            "decision_style": "注重教育理念是否科学，会详细了解教学方法",
            "initial_attitude": "感兴趣但专业审视",
            "concerns": ["教学方法是否科学", "是否会增加孩子负担"],
        },
        "scenario": {
            "context": "在教育论坛看到课程介绍后主动联系",
            "product_interest": "思维训练课程（基础班）",
            "success_trigger": "认可教育理念，希望带孩子体验后再决定",
        },
    },
]


async def seed():
    async with async_session_factory() as session:
        # Seed customers
        for data in CUSTOMERS:
            result = await session.execute(
                select(Customer).where(Customer.id == data["id"])
            )
            if not result.scalar_one_or_none():
                customer = Customer(**data)
                session.add(customer)
                print(f"  Added customer: {data['name']} ({data['id']})")
            else:
                print(f"  Skipped (exists): {data['name']}")

        # Seed admin user
        result = await session.execute(select(User).where(User.phone == "13800000000"))
        if not result.scalar_one_or_none():
            admin = User(
                phone="13800000000",
                password_hash=hash_password("123456"),
                name="管理员",
                role="admin",
            )
            session.add(admin)
            print("  Added admin user (phone: 13800000000, password: 123456)")
        else:
            print("  Skipped admin (exists)")

        await session.commit()
        print("\nSeed completed!")


if __name__ == "__main__":
    asyncio.run(seed())
