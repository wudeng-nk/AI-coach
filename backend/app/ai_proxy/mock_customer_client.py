from __future__ import annotations

import random
from dataclasses import dataclass, field


@dataclass
class ConversationState:
    """Track simulated customer conversation progress"""

    turn: int = 0
    attitude: float = 30.0  # 0-100 scale, starts skeptical
    interested_topics: list[str] = field(default_factory=list)
    raised_objections: list[str] = field(default_factory=list)
    is_purchased: bool = False


# Attitude change per turn to simulate progression
EMOTIONS = ["neutral", "skeptical", "curious", "interested", "positive", "excited", "hesitant", "convinced"]


class MockCustomerClient:
    """Mock simulated customer dialog client for development.

    Simulates a parent (typically a mother) shopping for education courses
    for their child. The conversation progresses from skeptical to interested
    based on the salesperson's (user's) performance.
    """

    _conversations: dict[str, ConversationState] = {}

    # ── Opening lines ──────────────────────────────────────────────
    OPENINGS = [
        "你好，我在朋友圈看到你们的广告，想了解一下你们是做什么的？",
        "您好，我家孩子今年5岁了，朋友推荐说你们这边有思维课，是什么样的课程啊？",
        "你好，我想给我家孩子报个兴趣班，看到你们说可以免费体验，具体怎么体验？",
        "您好，我收到你们的短信说有教育讲座，想问问是什么样的讲座？",
        "你好，之前在商场看到你们的展位，想了解一下你们的课程，孩子现在上一年级了。",
    ]

    # ── Response templates by conversation phase ────────────────────
    # Early phase (turn 1-2): Skeptical, asking basic questions
    EARLY_RESPONSES = [
        {
            "reply": "哦，这样啊。那你们的课程和普通的思维训练有什么不一样吗？我看外面也有很多类似的机构。",
            "emotion": "skeptical",
            "attitude_change": 5,
        },
        {
            "reply": "嗯...听起来还不错，但是我怎么知道真的有效果呢？毕竟孩子还小，我不想给他太大压力。",
            "emotion": "skeptical",
            "attitude_change": 3,
        },
        {
            "reply": "你们这个一节课多长时间？一周上几次？我们家平时作业也挺多的，怕孩子顾不过来。",
            "emotion": "neutral",
            "attitude_change": 5,
        },
        {
            "reply": "价格怎么样？现在报兴趣班花销挺大的，我们家还有一个老二要养呢。",
            "emotion": "neutral",
            "attitude_change": 2,
        },
        {
            "reply": "你们的老师都是什么背景啊？教这么小的孩子，老师要有耐心才行。",
            "emotion": "curious",
            "attitude_change": 8,
        },
    ]

    # Middle phase (turn 3-5): Getting interested, deeper questions
    MIDDLE_RESPONSES = [
        {
            "reply": "小班制倒是挺好的，我家孩子在大班就容易走神。那你们这个体验课是免费的吗？体验完会不会一直打电话催报名？",
            "emotion": "curious",
            "attitude_change": 10,
        },
        {
            "reply": "如果能出具能力评估报告的话倒是挺有吸引力。我之前也带孩子做过一些测评，但感觉都不太专业。你们的测评是自主研发的吗？",
            "emotion": "interested",
            "attitude_change": 12,
        },
        {
            "reply": "听你说了这么多，确实和别的机构不太一样。不过说实话，价格还是有点超出我的预算，有没有什么优惠活动？",
            "emotion": "interested",
            "attitude_change": 10,
        },
        {
            "reply": "你们有家长反馈或者学员案例吗？我想看看其他孩子学了之后的效果。毕竟说得再好，还是想看到真实的例子。",
            "emotion": "curious",
            "attitude_change": 8,
        },
        {
            "reply": "如果说年报有折扣的话，倒是可以考虑。但是万一孩子学了几次不想学了怎么办？可以退款吗？",
            "emotion": "hesitant",
            "attitude_change": 7,
        },
    ]

    # Late phase (turn 6+): Decision making
    LATE_POSITIVE_RESPONSES = [
        {
            "reply": "嗯...那好吧，我觉得可以先试试体验课看看。你们最近什么时候可以安排？最好是周末的时间。",
            "emotion": "positive",
            "attitude_change": 15,
        },
        {
            "reply": "听起来确实挺专业的。我回去和孩子爸爸商量一下，如果没什么问题的话应该会报名的。体验课先给我们约一个吧。",
            "emotion": "convinced",
            "attitude_change": 18,
        },
        {
            "reply": "好吧，你们这个确实比之前了解的那几家要专业一些。先报一个季度试试吧，效果好的话再续报。怎么付款？",
            "emotion": "excited",
            "attitude_change": 20,
        },
    ]

    LATE_NEGATIVE_RESPONSES = [
        {
            "reply": "我还是要再考虑考虑吧，毕竟这不是一笔小钱。我先了解一下，有需要再联系你们。",
            "emotion": "hesitant",
            "attitude_change": -5,
        },
        {
            "reply": "嗯...我再和其他几家对比一下，你们的价格确实比XX要贵一些。我想多看看再做决定。",
            "emotion": "skeptical",
            "attitude_change": -3,
        },
        {
            "reply": "谢谢你的介绍，但是我感觉现在可能还不是最好的时机。孩子刚开学，等稳定了再说吧。",
            "emotion": "neutral",
            "attitude_change": -2,
        },
    ]

    # ── Keyword-triggered specific responses ────────────────────────
    KEYWORD_RESPONSES: dict[str, dict] = {
        "体验课": {
            "reply": "体验课是免费的吗？需要带什么材料吗？大概多长时间？我想提前安排一下时间。",
            "emotion": "curious",
            "attitude_change": 10,
        },
        "优惠": {
            "reply": "有什么优惠活动？现在报名的话最优惠的方案是什么？如果报年报的话能省多少？",
            "emotion": "interested",
            "attitude_change": 8,
        },
        "老师": {
            "reply": "教我们家孩子的老师有多少年经验啊？可以提前了解一下老师的情况吗？之前遇到过老师不太负责的情况，所以比较在意这个。",
            "emotion": "curious",
            "attitude_change": 6,
        },
        "效果": {
            "reply": "效果怎么保证呢？如果学了一段时间没什么变化怎么办？你们有没有什么数据或者案例可以看看？",
            "emotion": "skeptical",
            "attitude_change": 5,
        },
        "退款": {
            "reply": "退款方便吗？万一学了几次孩子不适应，我不想交了钱退不回来。之前在别的机构就遇到过这种事。",
            "emotion": "hesitant",
            "attitude_change": 3,
        },
        "试听": {
            "reply": "试听课是和正式课一样的内容吗？试听的时候家长可以旁听吗？我想看看老师怎么上课的。",
            "emotion": "interested",
            "attitude_change": 10,
        },
        "价格": {
            "reply": "这个价格说实话不便宜啊...别的机构也有类似课程，价格比你们低一些。你们贵在哪里呢？",
            "emotion": "skeptical",
            "attitude_change": -2,
        },
        "报名": {
            "reply": "报名需要什么材料？可以先占个名额吗？我怕到时候想报又满了。",
            "emotion": "positive",
            "attitude_change": 15,
        },
    }

    def _get_state(self, session_id: str) -> ConversationState:
        if session_id not in self._conversations:
            self._conversations[session_id] = ConversationState()
        return self._conversations[session_id]

    async def get_opening(self, customer_id: str, session_id: str) -> dict:
        """Generate the customer's opening message to start the conversation."""
        state = self._get_state(session_id)
        state.turn = 0
        state.attitude = 30.0
        opening = random.choice(self.OPENINGS)
        return {
            "reply": opening,
            "emotion": "neutral",
            "is_purchased": False,
            "attitude_change": 0,
        }

    async def chat(
        self,
        customer_id: str,
        session_id: str,
        message: str,
        dialogue_history: list[dict] | None = None,
    ) -> dict:
        """Simulate a customer's response based on conversation progress.

        The response varies based on:
        - Conversation turn number (early/middle/late phase)
        - Keyword matching in the salesperson's message
        - Current attitude score
        """
        state = self._get_state(session_id)
        state.turn += 1

        # Check for keyword-triggered responses first
        for keyword, response in self.KEYWORD_RESPONSES.items():
            if keyword in message:
                state.attitude = min(100, state.attitude + response["attitude_change"])
                # Positive keywords in late phase may trigger purchase
                if state.turn >= 6 and state.attitude >= 70 and keyword in ("报名", "试听"):
                    state.is_purchased = True
                    return {
                        "reply": "好的，那就这么定了！你们帮我安排一下吧，我信赖你们的专业。什么时候可以开始上课？",
                        "emotion": "excited",
                        "is_purchased": True,
                        "attitude_change": 25,
                    }
                result = {**response, "is_purchased": False}
                return result

        # Phase-based responses
        if state.turn <= 2:
            # Early phase: skeptical, asking basic questions
            response = random.choice(self.EARLY_RESPONSES)
        elif state.turn <= 5:
            # Middle phase: getting interested
            response = random.choice(self.MIDDLE_RESPONSES)
        else:
            # Late phase: decision making
            if state.attitude >= 65:
                response = random.choice(self.LATE_POSITIVE_RESPONSES)
                # High attitude after enough turns triggers purchase
                if state.turn >= 7 and state.attitude >= 75:
                    state.is_purchased = True
                    return {
                        "reply": "好的，我觉得可以！你们帮我安排一下吧。请问报名需要准备什么材料？可以用微信支付吗？",
                        "emotion": "excited",
                        "is_purchased": True,
                        "attitude_change": 25,
                    }
            else:
                response = random.choice(self.LATE_NEGATIVE_RESPONSES)

        # Update attitude
        state.attitude = max(0, min(100, state.attitude + response["attitude_change"]))

        result = {**response, "is_purchased": state.is_purchased}
        return result
