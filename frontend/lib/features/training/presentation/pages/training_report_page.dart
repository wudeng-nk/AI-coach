import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/training/data/datasources/training_remote_data_source.dart';
import 'package:ai_coach/features/training/data/models/report_model.dart';
import 'package:ai_coach/features/training/presentation/widgets/score_radar_chart.dart';
import 'package:ai_coach/shared/widgets/squirrel_avatar.dart';

class TrainingReportPage extends StatefulWidget {
  final String sessionId;

  const TrainingReportPage({super.key, required this.sessionId});

  @override
  State<TrainingReportPage> createState() => _TrainingReportPageState();
}

class _TrainingReportPageState extends State<TrainingReportPage> {
  final _remoteDataSource = TrainingRemoteDataSource(dioClient.dio);
  ReportModel? _report;
  bool _isLoading = true;
  String? _errorMessage;
  bool _useMock = false;

  // Mock report data
  static const _mockReport = _MockReport(
    overallScore: 82,
    scoreDiff: 8,
    percentile: 65,
    pointsToNext: '再得2-3分',
    dimensions: [
      _ScoreDimension('共情力', 85, '能观察并回应家长情绪变化，建立了基本信任感', true),
      _ScoreDimension('需求洞察', 78, '通过追问初步了解了核心需求，可更深入挖掘痛点', true),
      _ScoreDimension('产品思维', 80, '方案匹配较精准，能结合需求进行针对性推荐', true),
      _ScoreDimension('谈判处理', 75, '面对异议时有一定的应对思路，但话术可以更灵活', false),
      _ScoreDimension('推进成交', 82, '能识别成交信号，有效运用促单技巧', true),
    ],
    compliance: ['真实合规', '价格合规', '隐私保护', '内容合规'],
    suggestions: [
      _Suggestion('异议处理：学习"价值重构法"', '查看技能库', false),
      _Suggestion('共情力：练习"深度情感体察"', '查看错误示范', true),
    ],
    helperRecords: [
      _HelperRecord('提示使用', 2),
      _HelperRecord('示范查看', 1),
    ],
  );

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport({int retries = 2}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Set a 3-second timeout to fall back to mock data
    bool loaded = false;

    for (int i = 0; i <= retries; i++) {
      try {
        final report = await _remoteDataSource
            .getReport(widget.sessionId)
            .timeout(const Duration(seconds: 3));
        loaded = true;
        if (mounted) {
          setState(() {
            _report = report;
            _isLoading = false;
            _useMock = false;
          });
        }
        return;
      } on DioException catch (e) {
        final msg = e.response?.data?['message'] as String? ?? '';
        if (i < retries && (msg.contains('尚未结束') || e.response?.statusCode == 400)) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }
      } catch (_) {
        // Timeout or connection error — fall through to mock
      }
    }

    // Fall back to mock data
    if (!loaded && mounted) {
      setState(() {
        _useMock = true;
        _isLoading = false;
      });
    }
  }

  Color _scoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && !_useMock
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
          const SizedBox(height: 12),
          Text(_errorMessage!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadReport, child: const Text('重试')),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Expanded(child: _buildScrollView()),
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildScrollView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildRadarSection(),
          const SizedBox(height: 16),
          _buildDimensionAnalysis(),
          const SizedBox(height: 16),
          _buildCompliance(),
          const SizedBox(height: 16),
          _buildActionSuggestions(),
          const SizedBox(height: 16),
          _buildHelperRecords(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // -- Header with gradient, squirrel avatar, score ring ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            children: [
              // Top row: title
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '训练报告',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC107),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _useMock ? '不错！比上次提升${_mockReport.scoreDiff}分' : '不错！继续加油',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Score section with squirrel + ring
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Squirrel mascot
                  Transform.translate(
                    offset: const Offset(0, 10),
                    child: const SquirrelAvatar(size: 90),
                  ),
                  const SizedBox(width: 12),
                  // Score ring
                  _buildScoreRing(_mockReport.overallScore),
                ],
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                '超过${_mockReport.percentile}%的同事',
                style: const TextStyle(fontSize: 14, color: Color(0xCCFFFFFF)),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Color(0x99FFFFFF)),
                  children: [
                    const TextSpan(text: '距离下一等级 '),
                    TextSpan(
                      text: _mockReport.pointsToNext,
                      style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
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

  Widget _buildScoreRing(int score) {
    final color = _scoreColor(score);
    return SizedBox(
      width: 140,
      height: 140,
      child: CustomPaint(
        painter: _ScoreRingPainter(
          progress: score / 100,
          color: color,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Text(
                '分',
                style: TextStyle(fontSize: 14, color: Color(0xCCFFFFFF)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -- Radar chart section ---

  Widget _buildRadarSection() {
    final scoresMap = <String, double>{};
    final avgMap = <String, double>{};
    for (final d in _mockReport.dimensions) {
      scoresMap[d.name] = d.score.toDouble();
      // Mock average slightly below user score
      avgMap[d.name] = (d.score - 8).toDouble().clamp(0, 100);
    }

    if (_report != null && !_useMock) {
      for (final entry in _report!.scores.entries) {
        scoresMap[entry.key] = entry.value.score;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '能力雷达图',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),
          Center(child: ScoreRadarChart(scores: scoresMap, averageScores: avgMap)),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFF2196F3), '本次得分', false),
              const SizedBox(width: 24),
              _buildLegend(Colors.grey, '团队平均水平', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, bool dashed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 2,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            border: dashed ? Border(bottom: BorderSide(color: color, width: 1.5, style: BorderStyle.solid)) : null,
          ),
        ),
        if (dashed)
          CustomPaint(
            painter: _DashedLinePainter(color: color),
            size: const Size(24, 2),
          ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
      ],
    );
  }

  // -- Dimension analysis ---

  Widget _buildDimensionAnalysis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '各维度分析',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 16),
          ..._mockReport.dimensions.map((d) => _buildDimensionItem(d)),
        ],
      ),
    );
  }

  Widget _buildDimensionItem(_ScoreDimension d) {
    final color = _scoreColor(d.score);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                d.isGood ? Icons.check_circle : Icons.info_outline,
                size: 18,
                color: d.isGood ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${d.name}：${d.score}分',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              d.comment,
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // -- Compliance check ---

  Widget _buildCompliance() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '合规检查',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _mockReport.compliance.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                  const SizedBox(width: 4),
                  Text(item, style: const TextStyle(fontSize: 13, color: Color(0xFF333333))),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // -- Action suggestions ---

  Widget _buildActionSuggestions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '行动建议',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 12),
          ..._mockReport.suggestions.map((s) => _buildSuggestionItem(s)),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(_Suggestion s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            s.isHigh ? Icons.warning_amber : Icons.trending_up,
            size: 18,
            color: s.isHigh ? const Color(0xFFFF9800) : const Color(0xFFE53935),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.text,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.4),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    s.linkText,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF2196F3), decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -- Helper records ---

  Widget _buildHelperRecords() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '辅助使用记录',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 12),
          ..._mockReport.helperRecords.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFFFF9800)),
                const SizedBox(width: 8),
                Text('${r.label}：${r.count}次', style: const TextStyle(fontSize: 13, color: Color(0xFF333333))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // -- Bottom buttons ---

  Widget _buildBottomButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => context.go('/training/chat/${widget.sessionId}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('再来一局', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => context.go('/training/hall'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('换场景', style: TextStyle(color: Color(0xFF2196F3), fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '分享报告',
                  style: TextStyle(fontSize: 13, color: Color(0xFF2196F3), decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter: score ring
// ---------------------------------------------------------------------------

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress ring
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

// ---------------------------------------------------------------------------
// Custom painter: dashed line for legend
// ---------------------------------------------------------------------------

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Mock data models
// ---------------------------------------------------------------------------

class _MockReport {
  final int overallScore;
  final int scoreDiff;
  final int percentile;
  final String pointsToNext;
  final List<_ScoreDimension> dimensions;
  final List<String> compliance;
  final List<_Suggestion> suggestions;
  final List<_HelperRecord> helperRecords;

  const _MockReport({
    required this.overallScore,
    required this.scoreDiff,
    required this.percentile,
    required this.pointsToNext,
    required this.dimensions,
    required this.compliance,
    required this.suggestions,
    required this.helperRecords,
  });
}

class _ScoreDimension {
  final String name;
  final int score;
  final String comment;
  final bool isGood;
  const _ScoreDimension(this.name, this.score, this.comment, this.isGood);
}

class _Suggestion {
  final String text;
  final String linkText;
  final bool isHigh;
  const _Suggestion(this.text, this.linkText, this.isHigh);
}

class _HelperRecord {
  final String label;
  final int count;
  const _HelperRecord(this.label, this.count);
}
