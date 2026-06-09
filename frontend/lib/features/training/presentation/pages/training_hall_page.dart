import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/squirrel_avatar.dart';

class TrainingHallPage extends StatefulWidget {
  const TrainingHallPage({super.key});

  @override
  State<TrainingHallPage> createState() => _TrainingHallPageState();
}

class _TrainingHallPageState extends State<TrainingHallPage> {
  int _currentPage = 0;

  static const _scenes = [
    _SceneData(
      id: 'S-01',
      name: '电话邀约到店',
      icon: Icons.phone_in_talk,
      difficulty: 3,
      objectives: ['开场白', '约到店时间', '处理简单疑问'],
      duration: '8分钟',
      completedCount: 12,
      status: _SceneStatus.unlocked,
      goal: '通过电话沟通，引导家长到店体验课程，提升到店转化率',
      skills: [
        _SkillDimension(name: '开场白设计', score: 75),
        _SkillDimension(name: '需求挖掘', score: 80),
        _SkillDimension(name: '异议处理', score: 65),
        _SkillDimension(name: '促成到店', score: 70),
      ],
      avgCallDuration: '3分15秒',
      conversionRate: '68%',
      satisfaction: '4.2/5.0',
    ),
    _SceneData(
      id: 'S-02',
      name: '首次到店接待',
      icon: Icons.storefront,
      difficulty: 4,
      objectives: ['迎宾流程', '需求初步沟通', '引导参观体验'],
      duration: '12分钟',
      completedCount: 5,
      status: _SceneStatus.unlocked,
      goal: '做好首次到店接待，建立信任感，引导家长深入了解课程',
      skills: [
        _SkillDimension(name: '迎宾礼仪', score: 85),
        _SkillDimension(name: '需求初步沟通', score: 60),
        _SkillDimension(name: '课程介绍', score: 55),
        _SkillDimension(name: '体验引导', score: 70),
      ],
      avgCallDuration: '25分钟',
      conversionRate: '45%',
      satisfaction: '3.8/5.0',
    ),
    _SceneData(
      id: 'S-03',
      name: '需求深度挖掘',
      icon: Icons.psychology,
      difficulty: 4,
      objectives: ['SPIN提问法', '痛点确认', '需求优先级排序'],
      duration: '15分钟',
      completedCount: 0,
      status: _SceneStatus.locked,
      goal: '运用SPIN提问法深度挖掘家长需求，精准定位痛点',
      skills: [
        _SkillDimension(name: 'SPIN提问', score: 40),
        _SkillDimension(name: '痛点确认', score: 35),
        _SkillDimension(name: '需求排序', score: 30),
        _SkillDimension(name: '共鸣建立', score: 45),
      ],
      avgCallDuration: '--',
      conversionRate: '--',
      satisfaction: '--',
    ),
    _SceneData(
      id: 'S-04',
      name: '方案推荐与异议处理',
      icon: Icons.handshake,
      difficulty: 5,
      objectives: ['方案匹配呈现', '价格异议处理', '竞品对比应对'],
      duration: '18分钟',
      completedCount: 0,
      status: _SceneStatus.locked,
      goal: '精准匹配方案，专业处理异议，化解竞品干扰',
      skills: [
        _SkillDimension(name: '方案匹配', score: 30),
        _SkillDimension(name: '价格谈判', score: 25),
        _SkillDimension(name: '竞品对比', score: 20),
        _SkillDimension(name: '价值传递', score: 35),
      ],
      avgCallDuration: '--',
      conversionRate: '--',
      satisfaction: '--',
    ),
    _SceneData(
      id: 'S-05',
      name: '逼单与签约',
      icon: Icons.edit_document,
      difficulty: 5,
      objectives: ['促成信号识别', '限时优惠运用', '签约流程引导'],
      duration: '15分钟',
      completedCount: 0,
      status: _SceneStatus.locked,
      goal: '识别购买信号，巧妙运用促单技巧，引导顺利签约',
      skills: [
        _SkillDimension(name: '信号识别', score: 20),
        _SkillDimension(name: '促单技巧', score: 15),
        _SkillDimension(name: '异议化解', score: 25),
        _SkillDimension(name: '流程引导', score: 20),
      ],
      avgCallDuration: '--',
      conversionRate: '--',
      satisfaction: '--',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildCardPager()),
                _buildPageIndicator(),
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    '提示：左右滑动查看更多场景',
                    style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ),
                _buildLockedScenes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Row(
            children: [
              const SquirrelAvatar(size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择训练场景',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentPage == 0 ? '建议从电话邀约开始！' : '完成前置场景即可解锁',
                      style: const TextStyle(fontSize: 13, color: Color(0xCCFFFFFF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardPager() {
    return PageView.builder(
      itemCount: _scenes.length,
      onPageChanged: (i) => setState(() => _currentPage = i),
      controller: PageController(viewportFraction: 0.9),
      itemBuilder: (context, index) {
        final scene = _scenes[index];
        return _SceneCard(
          scene: scene,
          index: index,
          total: _scenes.length,
          onStart: () {
            context.push('/training/parents/${scene.id}');
          },
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_scenes.length, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _currentPage ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _currentPage
                  ? const Color(0xFF2196F3)
                  : const Color(0xFFD0D0D0),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLockedScenes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          Expanded(child: _LockedSceneChip(label: 'Stretch场景')),
          const SizedBox(width: 12),
          Expanded(child: _LockedSceneChip(label: '成功案例讲述')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _SkillDimension {
  final String name;
  final int score; // 0-100
  const _SkillDimension({required this.name, required this.score});
}

class _SceneData {
  final String id;
  final String name;
  final IconData icon;
  final int difficulty;
  final List<String> objectives;
  final String duration;
  final int completedCount;
  final _SceneStatus status;
  final String goal;
  final List<_SkillDimension> skills;
  final String avgCallDuration;
  final String conversionRate;
  final String satisfaction;

  const _SceneData({
    required this.id,
    required this.name,
    required this.icon,
    required this.difficulty,
    required this.objectives,
    required this.duration,
    required this.completedCount,
    required this.status,
    required this.goal,
    required this.skills,
    required this.avgCallDuration,
    required this.conversionRate,
    required this.satisfaction,
  });
}

enum _SceneStatus { unlocked, locked }

// ---------------------------------------------------------------------------
// Locked scene chip
// ---------------------------------------------------------------------------

class _LockedSceneChip extends StatelessWidget {
  final String label;
  const _LockedSceneChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 14, color: Color(0xFFBDBDBD)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flip card – front + back with animation
// ---------------------------------------------------------------------------

class _SceneCard extends StatefulWidget {
  final _SceneData scene;
  final int index;
  final int total;
  final VoidCallback onStart;

  const _SceneCard({
    required this.scene,
    required this.index,
    required this.total,
    required this.onStart,
  });

  @override
  State<_SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<_SceneCard>
    with SingleTickerProviderStateMixin {
  bool _showFront = true;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _showFront = !_showFront);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * 3.14159265; // pi
        final showFrontNow = _animation.value <= 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(showFrontNow ? angle : angle - 3.14159265),
          child: showFrontNow
              ? _buildFront(context)
              : _buildBack(context),
        );
      },
    );
  }

  // ---- FRONT ----
  Widget _buildFront(BuildContext context) {
    final isLocked = widget.scene.status == _SceneStatus.locked;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '[${widget.index + 1}/${widget.total}]',
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 16),
            // icon + title
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.scene.icon, size: 28, color: const Color(0xFF1976D2)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.scene.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < widget.scene.difficulty ? Icons.star : Icons.star_border,
                            size: 16,
                            color: i < widget.scene.difficulty
                                ? const Color(0xFFFFC107)
                                : const Color(0xFFD0D0D0),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '目标：成功邀约家长到店',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 10),
            ...widget.scene.objectives.map((obj) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF2196F3)),
                  const SizedBox(width: 8),
                  Text(obj, style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                ],
              ),
            )),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(widget.scene.duration, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                const SizedBox(width: 16),
                Text('已练${widget.scene.completedCount}次',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _flip,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2196F3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('查看详情',
                          style: TextStyle(color: Color(0xFF2196F3), fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: isLocked ? null : widget.onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        disabledBackgroundColor: const Color(0xFFBDBDBD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isLocked ? '未解锁' : '开始',
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---- BACK ----
  Widget _buildBack(BuildContext context) {
    final s = widget.scene;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '${s.name} - 场景解析',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            // 场景核心目标
            const Text(
              '场景核心目标',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icon, size: 20, color: const Color(0xFF2196F3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.goal,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 核心技能维度
            const Text(
              '核心技能维度',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 10),
            ...s.skills.map((skill) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(skill.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                      Text('${skill.score}/100',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: skill.score >= 70
                                ? const Color(0xFF4CAF50)
                                : skill.score >= 40
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFFE53935),
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: skill.score / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        skill.score >= 70
                            ? const Color(0xFF4CAF50)
                            : skill.score >= 40
                                ? const Color(0xFFFF9800)
                                : const Color(0xFFE53935),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            const Spacer(),
            // 历史表现数据
            const Text(
              '历史表现数据',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _DataChip(label: '平均通话时长', value: s.avgCallDuration, color: const Color(0xFF2196F3)),
                const SizedBox(width: 8),
                _DataChip(label: '到店转化率', value: s.conversionRate, color: const Color(0xFF4CAF50)),
                const SizedBox(width: 8),
                _DataChip(label: '家长满意度', value: s.satisfaction, color: const Color(0xFFFF9800)),
              ],
            ),
            const SizedBox(height: 16),
            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _flip,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF999999)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('返回正面',
                          style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: s.status == _SceneStatus.locked ? null : widget.onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        disabledBackgroundColor: const Color(0xFFBDBDBD),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('开始训练',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data chip (历史数据小标签)
// ---------------------------------------------------------------------------

class _DataChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _DataChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }
}
