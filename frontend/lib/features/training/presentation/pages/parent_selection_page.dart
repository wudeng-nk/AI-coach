import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_coach/shared/widgets/squirrel_avatar.dart';

class ParentSelectionPage extends StatefulWidget {
  final String sceneId;
  const ParentSelectionPage({super.key, required this.sceneId});

  @override
  State<ParentSelectionPage> createState() => _ParentSelectionPageState();
}

class _ParentSelectionPageState extends State<ParentSelectionPage>
    with TickerProviderStateMixin {
  int _selectedParentIndex = 0;
  int _selectedStudentIndex = 0;
  bool _isFlipped = false;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    _isFlipped = !_isFlipped;
  }

  static const _parents = [
    // 焦虑型
    _ParentData(
      id: 'P-01',
      name: '焦虑型-张宝妈',
      subtitle: '高压力版',
      avatar: 'assets/images/parent_anxious.png',
      difficulty: 3,
      quote: '"孩子再不进步就来不及了..."',
      traits: ['急切', '紧张', '话多'],
      coreNeeds: ['快速看到明显效果', '证明比其他机构更好', '获得心安感'],
      weakness: '容易受负面信息扰乱决策',
      recommendedSkills: ['热情三问句', '价值塑造法', '痛点具象化'],
      passRate: '65%',
    ),
    _ParentData(
      id: 'P-02',
      name: '焦虑型-赵宝妈',
      subtitle: '时间紧迫版',
      avatar: 'assets/images/parent_anxious.png',
      difficulty: 3,
      quote: '"时间真的不够用了，能不能快点见效？"',
      traits: ['紧迫', '焦虑', '催促'],
      coreNeeds: ['高效的学习方案', '明确的时间节点', '快速响应服务'],
      weakness: '时间压力下容易冲动决策',
      recommendedSkills: ['紧迫感引导法', '时间规划法', '快速信任建立'],
      passRate: '62%',
    ),
    // 迷茫型
    _ParentData(
      id: 'P-03',
      name: '迷茫型-王宝爸',
      subtitle: '信息过载版',
      avatar: 'assets/images/parent_confused.png',
      difficulty: 2,
      quote: '"我也不太懂，看了好几家了，越看越迷糊..."',
      traits: ['犹豫', '信息多', '无判断力'],
      coreNeeds: ['专业建议和方向', '简单易懂的方案', '可信赖的顾问'],
      weakness: '信息过载导致决策困难',
      recommendedSkills: ['需求诊断法', '方案对比表', '专家背书法'],
      passRate: '72%',
    ),
    // 理性型
    _ParentData(
      id: 'P-04',
      name: '理性型-李宝爸',
      subtitle: '数据驱动版',
      avatar: 'assets/images/parent_rational.png',
      difficulty: 4,
      quote: '"你们的数据怎么样？通过率多少？和其他机构比呢？"',
      traits: ['务实', '数据驱动', '抗拒推销'],
      coreNeeds: ['数据支撑的效果证明', '清晰的课程体系', '性价比分析'],
      weakness: '一旦认可会非常忠诚',
      recommendedSkills: ['数据说服法', '案例展示法', '理性对比法'],
      passRate: '48%',
    ),
    _ParentData(
      id: 'P-05',
      name: '理性型-陈宝爸',
      subtitle: '技术质疑版',
      avatar: 'assets/images/parent_rational.png',
      difficulty: 5,
      quote: '"你们的AI技术真的有用吗？有论文支撑吗？"',
      traits: ['技术敏感', '质疑', '求证型'],
      coreNeeds: ['技术原理的透明解释', '第三方认证和背书', '可验证的效果数据'],
      weakness: '技术认同后会主动传播推荐',
      recommendedSkills: ['技术展示法', '第三方验证法', '逻辑论证法'],
      passRate: '38%',
    ),
    // 观望型
    _ParentData(
      id: 'P-06',
      name: '观望型-周宝妈',
      subtitle: '社交影响型',
      avatar: 'assets/images/parent_observer.png',
      difficulty: 2,
      quote: '"我先了解一下，看看身边朋友怎么说..."',
      traits: ['好奇', '社交驱动', '随大流'],
      coreNeeds: ['轻松了解不压迫', '体验感和口碑', '自由度高的选择'],
      weakness: '没有紧迫感容易流失',
      recommendedSkills: ['体验邀约法', '口碑传递法', '社交证明法'],
      passRate: '55%',
    ),
  ];

  static const _students = [
    _StudentData(
      id: 'ST-01',
      name: '小学低年级',
      avatar: 'assets/images/student_lower.png',
      ageRange: '6-8岁',
      pressure: '兴趣启蒙期',
      difficultyBonus: 0.5,
    ),
    _StudentData(
      id: 'ST-02',
      name: '小学高年级',
      avatar: 'assets/images/student_upper.png',
      ageRange: '10-12岁',
      pressure: '小升初压力',
      difficultyBonus: 1.0,
    ),
    _StudentData(
      id: 'ST-03',
      name: '初中低年级',
      avatar: 'assets/images/student_middle.png',
      ageRange: '12-14岁',
      pressure: '学业适应期',
      difficultyBonus: 1.0,
    ),
    _StudentData(
      id: 'ST-04',
      name: '初中毕业班',
      avatar: 'assets/images/student_middle.png',
      ageRange: '14-15岁',
      pressure: '中考冲刺',
      difficultyBonus: 1.5,
    ),
    _StudentData(
      id: 'ST-05',
      name: '高中低年级',
      avatar: 'assets/images/student_high.png',
      ageRange: '15-17岁',
      pressure: '学业规划期',
      difficultyBonus: 1.5,
    ),
    _StudentData(
      id: 'ST-06',
      name: '高中毕业班',
      avatar: 'assets/images/student_high.png',
      ageRange: '17-18岁',
      pressure: '高考冲刺',
      difficultyBonus: 2.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF333333)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '选择对练对象',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 场景提示
          _buildSceneHint(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  // 选择家长类型
                  _buildParentSection(),
                  const SizedBox(height: 16),
                  // 选择学生类型
                  _buildSection(
                    icon: Icons.school,
                    title: '选择学生类型',
                    currentIndex: _selectedStudentIndex,
                    total: _students.length,
                    onPrevious: _selectedStudentIndex > 0
                        ? () => setState(() => _selectedStudentIndex--)
                        : null,
                    onNext: _selectedStudentIndex < _students.length - 1
                        ? () => setState(() => _selectedStudentIndex++)
                        : null,
                    child: _buildStudentCard(_students[_selectedStudentIndex]),
                  ),
                  const SizedBox(height: 16),
                  // 当前组合预览
                  _buildCombinationPreview(),
                ],
              ),
            ),
          ),
          // 确认按钮
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildSceneHint() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const SquirrelAvatar(size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '推荐挑战焦虑型家长！',
                style: const TextStyle(fontSize: 13, color: Color(0xFF1976D2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentSection() {
    final parent = _parents[_selectedParentIndex];
    final t = Curves.easeInOut.transform(_flipController.value);
    final angle = t * 3.14159265;
    final showFront = t <= 0.5;
    final displayAngle = showFront ? angle : angle - 3.14159265;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行 (不翻转)
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: Color(0xFF1976D2)),
              const SizedBox(width: 6),
              const Text(
                '选择家长类型',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
              ),
              const Spacer(),
              Text(
                '[${_selectedParentIndex + 1}/${_parents.length}]',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 整个卡片翻转
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(displayAngle),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E8E8)),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.05),
                  ),
                ],
              ),
              child: SizedBox(
                height: 420,
                child: showFront
                    ? _buildParentCard(parent)
                    : _buildParentCardBack(parent),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 翻页器 (不翻转)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPagerArrow(
                onTap: _selectedParentIndex > 0
                    ? () {
                        if (_isFlipped) _toggleFlip();
                        setState(() => _selectedParentIndex--);
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              Row(
                children: List.generate(_parents.length, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _selectedParentIndex ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _selectedParentIndex
                          ? const Color(0xFF2196F3)
                          : const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              _buildPagerArrow(
                onTap: _selectedParentIndex < _parents.length - 1
                    ? () {
                        if (_isFlipped) _toggleFlip();
                        setState(() => _selectedParentIndex++);
                      }
                    : null,
                isNext: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPagerArrow({VoidCallback? onTap, bool isNext = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
        ),
        child: Icon(
          isNext ? Icons.chevron_right : Icons.chevron_left,
          size: 18,
          color: onTap != null ? const Color(0xFF1976D2) : const Color(0xFFD0D0D0),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required int currentIndex,
    required int total,
    required VoidCallback? onPrevious,
    required VoidCallback? onNext,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1976D2)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Spacer(),
              Text(
                '[${currentIndex + 1}/$total]',
                style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 卡片内容
          child,
          const SizedBox(height: 12),
          // 翻页指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 左箭头
              GestureDetector(
                onTap: onPrevious,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onPrevious != null ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 18,
                    color: onPrevious != null ? const Color(0xFF1976D2) : const Color(0xFFD0D0D0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 分页点
              Row(
                children: List.generate(total, (i) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == currentIndex ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? const Color(0xFF2196F3)
                          : const Color(0xFFD0D0D0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              // 右箭头
              GestureDetector(
                onTap: onNext,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onNext != null ? const Color(0xFFE3F2FD) : const Color(0xFFF5F5F5),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: onNext != null ? const Color(0xFF1976D2) : const Color(0xFFD0D0D0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParentCard(_ParentData parent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: 头像 + 名字/难度/通过率
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0F0F0),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: ClipOval(
                child: Image.asset(
                  parent.avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 32,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        parent.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          parent.subtitle,
                          style: const TextStyle(fontSize: 10, color: Color(0xFFE65100), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('难度：', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                      ...List.generate(5, (i) => Icon(
                        i < parent.difficulty ? Icons.star : Icons.star_border,
                        size: 14,
                        color: i < parent.difficulty ? const Color(0xFFFFC107) : const Color(0xFFD0D0D0),
                      )),
                      const Spacer(),
                      Text('通过率 ', style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                      Text(parent.passRate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2196F3))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 引言
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.format_quote, size: 16, color: Color(0xFFBDBDBD)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  parent.quote.replaceAll('"', ''),
                  style: const TextStyle(fontSize: 13, color: Color(0xFF555555), fontStyle: FontStyle.italic, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // 特征标签
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: parent.traits.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(t, style: const TextStyle(fontSize: 11, color: Color(0xFFE65100))),
          )).toList(),
        ),
        const SizedBox(height: 10),
        // 核心诉求
        _buildFrontInfoSection(
          icon: Icons.gps_fixed,
          iconColor: const Color(0xFF2196F3),
          title: '核心诉求',
          items: parent.coreNeeds,
        ),
        const SizedBox(height: 10),
        // 沟通难点
        _buildFrontInfoSection(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFFF9800),
          title: '沟通难点',
          items: [parent.weakness],
        ),
        // Spacer to push buttons to bottom
        const Spacer(),
        // 按钮
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: _toggleFlip,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('查看攻略',
                      style: TextStyle(color: Color(0xFF2196F3), fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('选择 →',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFrontInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Wrap(
            spacing: 6,
            runSpacing: 3,
            children: items.map((item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF999999),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
                const SizedBox(width: 4),
                Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF555555))),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildParentCardBack(_ParentData parent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            const Icon(Icons.local_fire_department, size: 16, color: Color(0xFFFF5722)),
            const SizedBox(width: 6),
            Text(
              parent.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 核心需求
        _buildGuideSection(
          icon: Icons.gps_fixed,
          iconColor: const Color(0xFF2196F3),
          title: '核心需求',
          items: parent.coreNeeds,
        ),
        const SizedBox(height: 10),

        // 弱点
        _buildGuideSection(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFFF9800),
          title: '弱点',
          items: [parent.weakness],
        ),
        const SizedBox(height: 10),

        // 推荐技能
        _buildGuideSection(
          icon: Icons.lightbulb_outline,
          iconColor: const Color(0xFF2196F3),
          title: '推荐技能',
          items: parent.recommendedSkills,
        ),
        const SizedBox(height: 10),

        // 通过率
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 16, color: Color(0xFF2196F3)),
            const SizedBox(width: 6),
            const Text(
              '通过率：',
              style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
            ),
            Text(
              parent.passRate,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ],
        ),
        // Spacer to push buttons to bottom
        const Spacer(),

        // 按钮
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: _toggleFlip,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF999999)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('返回',
                      style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('选择此家长 →',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF999999),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(_StudentData student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 头像
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF0F0F0),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: ClipOval(
                child: Image.asset(
                  student.avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school,
                    size: 32,
                    color: Color(0xFFBDBDBD),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.menu_book, size: 14, color: Color(0xFF1976D2)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${student.ageRange} | ${student.pressure}',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '难度系数：+${student.difficultyBonus}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // 选择按钮
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('选择 →', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildCombinationPreview() {
    final parent = _parents[_selectedParentIndex];
    final student = _students[_selectedStudentIndex];
    final combinedDifficulty = (parent.difficulty + student.difficultyBonus).round().clamp(1, 5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        children: [
          // 两个小头像
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF0F0F0),
            ),
            child: ClipOval(
              child: Image.asset(
                parent.avatar,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 18, color: Color(0xFFBDBDBD)),
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F0F0),
              ),
              child: ClipOval(
                child: Image.asset(
                  student.avatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 18, color: Color(0xFFBDBDBD)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${parent.name} × ${student.name}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
                Row(
                  children: [
                    const Text('综合难度：', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
                    ...List.generate(5, (i) => Icon(
                      i < combinedDifficulty ? Icons.star : Icons.star_border,
                      size: 12,
                      color: i < combinedDifficulty ? const Color(0xFFFFC107) : const Color(0xFFD0D0D0),
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
      ),
      child: SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            final parent = _parents[_selectedParentIndex];
            context.push('/training/chat/${parent.id}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '确认开始训练',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

class _ParentData {
  final String id;
  final String name;
  final String subtitle;
  final String avatar;
  final int difficulty; // 1-5
  final String quote;
  final List<String> traits;
  final List<String> coreNeeds;
  final String weakness;
  final List<String> recommendedSkills;
  final String passRate;

  const _ParentData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.difficulty,
    required this.quote,
    required this.traits,
    required this.coreNeeds,
    required this.weakness,
    required this.recommendedSkills,
    required this.passRate,
  });
}

class _StudentData {
  final String id;
  final String name;
  final String avatar;
  final String ageRange;
  final String pressure;
  final double difficultyBonus;

  const _StudentData({
    required this.id,
    required this.name,
    required this.avatar,
    required this.ageRange,
    required this.pressure,
    required this.difficultyBonus,
  });
}
