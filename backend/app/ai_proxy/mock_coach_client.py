from __future__ import annotations

import random
from dataclasses import dataclass


# ── Scoring dimensions ──────────────────────────────────────────────

@dataclass
class DimensionScore:
    name: str
    name_cn: str
    score: int
    comment: str


# ── Pre-built evaluation templates ──────────────────────────────────

HIGHLIGHT_TEMPLATES = [
    "开场白自然亲切，较好地建立了信任感。",
    "积极倾听客户需求，没有急于推销产品。",
    "在介绍课程体系时条理清晰，逻辑性强。",
    "对价格异议的处理比较到位，提供了多种方案。",
    "有效运用了社会证明（成功案例）增强说服力。",
    "及时捕捉到客户关注的重点（效果/师资），并针对性地展开说明。",
    "语气亲和力强，让客户感到被尊重和理解。",
    "对产品知识掌握扎实，回答客户问题时流畅自然。",
    "有效利用开放式提问引导客户表达真实需求。",
    "在客户犹豫时没有施加过大压力，节奏把控较好。",
    "对竞品的回应策略得当，以突出自身优势为主。",
    "成功营造出紧迫感，但又不显得过于功利。",
    "沟通中多次与客户确认理解是否准确，体现了专业素养。",
    "在谈及课程效果时有理有据，使用了具体数据支撑。",
    "对家长关心的退款政策给出了清晰的解释，消除了后顾之忧。",
]

IMPROVEMENT_TEMPLATES = [
    "开场时可以直接点明邀约目的，避免过多寒暄导致客户失去耐心。",
    "建议在了解客户需求时多使用开放式问题，而非封闭式问题。",
    "介绍产品时可以更有结构，先讲价值再讲价格，避免过早陷入价格讨论。",
    "面对异议时，建议先共情确认理解客户的顾虑，再进行回应。",
    "在促成成交时可以更主动一些，给出明确的下一步行动建议。",
    "可以适当运用紧迫感策略（如限时优惠、名额有限），但注意把握尺度。",
    "建议在对话中多使用客户的孩子相关的具体场景，增强代入感。",
    "处理价格异议时，建议引导客户关注价值而非单纯比较价格。",
    "可以多准备一些真实的学员案例，增强说服力的可信度。",
    "在客户表达犹豫时，建议使用假设成交法探寻客户真实顾虑。",
    "结束对话前建议做好下一步的明确约定（时间、事项），避免模糊结束。",
    "可以更多运用数据来支撑课程效果的陈述，而非仅靠口头描述。",
    "建议在发现客户兴趣点后深入展开，而非快速切换到下一个话题。",
    "沟通过程中可以适当使用复述和总结技巧，确保双方理解一致。",
    "面对竞品比较时，避免直接批评对手，应聚焦自身差异化优势。",
]

ANNOTATION_TEMPLATES = [
    {"dialogue_index": 0, "type": "positive", "comment": "开场白简洁有力，快速切入主题。"},
    {"dialogue_index": 0, "type": "negative", "comment": "开场过于冗长，建议更快进入正题。"},
    {"dialogue_index": 1, "type": "positive", "comment": "有效运用开放式提问了解客户需求。"},
    {"dialogue_index": 1, "type": "negative", "comment": "提问过于封闭，限制了客户表达的深度。"},
    {"dialogue_index": 2, "type": "positive", "comment": "产品介绍条理清晰，重点突出。"},
    {"dialogue_index": 2, "type": "negative", "comment": "产品介绍过于笼统，缺少针对性。"},
    {"dialogue_index": 3, "type": "positive", "comment": "对客户异议的回应有理有据。"},
    {"dialogue_index": 3, "type": "negative", "comment": "面对异议直接反驳，建议先共情再回应。"},
    {"dialogue_index": 4, "type": "positive", "comment": "有效运用案例增强说服力。"},
    {"dialogue_index": 4, "type": "negative", "comment": "缺少具体案例支撑，说服力不足。"},
    {"dialogue_index": 5, "type": "positive", "comment": "适时提出成交建议，把握了时机。"},
    {"dialogue_index": 5, "type": "negative", "comment": "成交时机不够成熟，建议继续挖掘需求。"},
]


class MockCoachClient:
    """Mock coach evaluation client for development.

    Generates realistic training evaluation reports based on
    dialogue content and session outcome.
    """

    def _calculate_base_score(self, dialogue: list[dict], end_reason: str) -> int:
        """Calculate base score influenced by dialogue length and outcome."""
        dialogue_length = len(dialogue)

        # Base score from dialogue length (more turns = more substantive conversation)
        if dialogue_length >= 10:
            length_bonus = 15
        elif dialogue_length >= 6:
            length_bonus = 10
        elif dialogue_length >= 3:
            length_bonus = 5
        else:
            length_bonus = 0

        # Base score from end_reason
        if end_reason == "purchased":
            outcome_score = 78
        elif end_reason == "customer_left":
            outcome_score = 55
        elif end_reason == "timeout":
            outcome_score = 60
        else:
            outcome_score = 50

        return min(95, outcome_score + length_bonus)

    def _generate_dimension_scores(
        self, base_score: int, end_reason: str, dialogue: list[dict]
    ) -> list[DimensionScore]:
        """Generate scores for each evaluation dimension with variation."""
        dimensions = [
            ("opening", "开场破冰"),
            ("needs_discovery", "需求挖掘"),
            ("product_presentation", "产品呈现"),
            ("objection_handling", "异议处理"),
            ("closing", "促成成交"),
            ("communication", "沟通技巧"),
        ]

        scores = []
        for i, (name, name_cn) in enumerate(dimensions):
            # Vary scores around base; some dimensions influenced by outcome
            variation = random.randint(-12, 8)

            # Closing score heavily influenced by purchase outcome
            if name == "closing":
                if end_reason == "purchased":
                    variation = random.randint(5, 15)
                else:
                    variation = random.randint(-15, -3)

            # Objection handling gets a boost for longer conversations
            if name == "objection_handling" and len(dialogue) >= 6:
                variation += random.randint(3, 8)

            score = max(40, min(98, base_score + variation))

            comment = self._get_dimension_comment(name, score)
            scores.append(DimensionScore(name=name, name_cn=name_cn, score=score, comment=comment))

        return scores

    def _get_dimension_comment(self, dimension: str, score: int) -> str:
        """Get a contextual comment for a dimension score."""
        comments = {
            "opening": {
                "high": "开场白自然流畅，快速拉近了与客户的距离，为后续沟通奠定了良好基础。",
                "mid": "开场基本得体，但可以更快速地切入正题，减少不必要的寒暄。",
                "low": "开场略显生硬，建议提前准备好开场白模板，增强亲和力和自信心。",
            },
            "needs_discovery": {
                "high": "通过层层深入的提问，精准把握了客户的核心需求和潜在顾虑。",
                "mid": "有一定的需求了解，但提问深度不够，建议多使用开放式问题和追问技巧。",
                "low": "需求挖掘不够深入，过多时间用于单向介绍，缺少与客户的双向互动。",
            },
            "product_presentation": {
                "high": "产品介绍条理清晰，重点突出，能够根据客户需求有针对性地展开说明。",
                "mid": "产品介绍较为完整，但可以更好地结合客户的具体情况进行个性化推荐。",
                "low": "产品介绍较为笼统，建议先了解客户需求再有针对性地介绍相关卖点。",
            },
            "objection_handling": {
                "high": "面对客户异议时沉着冷静，先共情再回应，有效化解了客户的顾虑。",
                "mid": "能够回应客户异议，但技巧有待提升，建议运用'感受-事实-价值'三步法。",
                "low": "面对异议处理略显被动，建议提前准备常见异议的应对话术。",
            },
            "closing": {
                "high": "精准把握成交时机，促单手法自然不生硬，成功达成成交。",
                "mid": "有一定促单意识，但时机把握和手法还可以更加成熟。",
                "low": "促单环节较为薄弱，建议学习运用假设成交法和紧迫感策略。",
            },
            "communication": {
                "high": "整体沟通节奏把控得当，语气亲和力强，展现了专业的销售素养。",
                "mid": "沟通基本顺畅，可以更多运用积极倾听和复述确认技巧。",
                "low": "沟通过程中互动不足，建议注意语速和语调的变化，增强感染力。",
            },
        }

        if score >= 80:
            level = "high"
        elif score >= 60:
            level = "mid"
        else:
            level = "low"

        return comments.get(dimension, comments["communication"])[level]

    def _select_highlights(
        self, dimension_scores: list[DimensionScore], count: int = 3
    ) -> list[str]:
        """Select highlight comments, biased toward high-scoring dimensions."""
        pool = list(HIGHLIGHT_TEMPLATES)
        # Add dimension-specific positive comments for high-scoring areas
        for ds in dimension_scores:
            if ds.score >= 75:
                pool.append(ds.comment)

        count = min(count, len(pool))
        return random.sample(pool, count)

    def _select_improvements(
        self, dimension_scores: list[DimensionScore], count: int = 3
    ) -> list[str]:
        """Select improvement comments, biased toward low-scoring dimensions."""
        pool = list(IMPROVEMENT_TEMPLATES)
        # Add dimension-specific suggestions for low-scoring areas
        for ds in dimension_scores:
            if ds.score < 65:
                pool.append(ds.comment)

        count = min(count, len(pool))
        return random.sample(pool, count)

    def _generate_annotations(
        self, dialogue: list[dict], dimension_scores: list[DimensionScore]
    ) -> list[dict]:
        """Generate dialogue annotations (inline comments on specific messages)."""
        annotations = []
        dialogue_len = len(dialogue)

        if dialogue_len == 0:
            return annotations

        # Calculate average score to decide annotation bias
        avg_score = sum(ds.score for ds in dimension_scores) / len(dimension_scores)

        # Pick a few dialogue indices to annotate
        indices_to_annotate: set[int] = set()

        # Always annotate the first user message (opening)
        for i, msg in enumerate(dialogue):
            if msg.get("role") == "user":
                indices_to_annotate.add(i)
                break

        # Annotate a middle and late message if available
        user_indices = [i for i, msg in enumerate(dialogue) if msg.get("role") == "user"]
        if len(user_indices) >= 2:
            indices_to_annotate.add(user_indices[len(user_indices) // 2])
        if len(user_indices) >= 3:
            indices_to_annotate.add(user_indices[-1])

        for idx in indices_to_annotate:
            # Pick positive or negative annotation based on score
            if avg_score >= 70:
                positive_pool = [a for a in ANNOTATION_TEMPLATES if a["type"] == "positive"]
                template = random.choice(positive_pool) if positive_pool else ANNOTATION_TEMPLATES[0]
            else:
                negative_pool = [a for a in ANNOTATION_TEMPLATES if a["type"] == "negative"]
                template = random.choice(negative_pool) if negative_pool else ANNOTATION_TEMPLATES[1]

            annotations.append({
                "dialogue_index": idx,
                "type": template["type"],
                "comment": template["comment"],
            })

        return annotations

    async def evaluate(
        self,
        session_id: str,
        customer_id: str,
        dialogue: list[dict],
        end_reason: str,
    ) -> dict:
        """Generate a complete training evaluation report."""
        base_score = self._calculate_base_score(dialogue, end_reason)

        dimension_scores = self._generate_dimension_scores(base_score, end_reason, dialogue)

        # Overall score is the weighted average of dimensions
        overall_score = int(sum(ds.score for ds in dimension_scores) / len(dimension_scores))
        # Clamp to realistic range
        overall_score = max(60, min(95, overall_score))

        highlights = self._select_highlights(dimension_scores)
        improvements = self._select_improvements(dimension_scores)
        annotations = self._generate_annotations(dialogue, dimension_scores)

        return {
            "session_id": session_id,
            "customer_id": customer_id,
            "overall_score": overall_score,
            "dimensions": [
                {
                    "name": ds.name,
                    "name_cn": ds.name_cn,
                    "score": ds.score,
                    "comment": ds.comment,
                }
                for ds in dimension_scores
            ],
            "highlights": highlights,
            "improvements": improvements,
            "dialogue_annotations": annotations,
        }
