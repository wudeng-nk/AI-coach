import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/core/network/dio_client.dart';
import 'package:ai_coach/features/training/data/datasources/training_remote_data_source.dart';
import 'package:ai_coach/features/training/data/models/report_model.dart';
import 'package:ai_coach/features/training/presentation/widgets/score_radar_chart.dart';

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

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport({int retries = 3}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    for (int i = 0; i <= retries; i++) {
      try {
        final report = await _remoteDataSource.getReport(widget.sessionId);
        if (mounted) {
          setState(() {
            _report = report;
            _isLoading = false;
          });
        }
        return;
      } on DioException catch (e) {
        final msg = e.response?.data?['message'] as String? ?? '';
        // If report not ready yet, retry after delay
        if (i < retries && (msg.contains('尚未结束') || e.response?.statusCode == 400)) {
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
        if (mounted) {
          setState(() {
            _errorMessage = msg.isNotEmpty ? msg : '加载报告失败';
            _isLoading = false;
          });
        }
        return;
      } catch (e) {
        if (i < retries) {
          await Future.delayed(Duration(seconds: 2));
          continue;
        }
        if (mounted) {
          setState(() {
            _errorMessage = '加载报告失败，请稍后重试';
            _isLoading = false;
          });
        }
        return;
      }
    }
  }

  Color _scoreColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('训练报告')),
      body: _buildBody(),
      bottomNavigationBar: _report != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ElevatedButton(
                  onPressed: () {
                    // Pop back to training hall
                    context.go('/training');
                  },
                  child: const Text('再练一次'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReport,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final report = _report!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallScore(report),
          const SizedBox(height: 24),
          _buildRadarChart(report),
          const SizedBox(height: 24),
          _buildScoreBreakdown(report),
          const SizedBox(height: 24),
          _buildHighlights(report),
          const SizedBox(height: 24),
          _buildImprovements(report),
          const SizedBox(height: 24),
          _buildDialogueReplay(report),
          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }

  // -- Overall score ---------------------------------------------------------

  Widget _buildOverallScore(ReportModel report) {
    final score = report.overallScore;
    final color = _scoreColor(score);

    return Center(
      child: Column(
        children: [
          const Text(
            '综合评分',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: color, width: 3),
            ),
            child: Center(
              child: Text(
                score.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Radar chart -----------------------------------------------------------

  Widget _buildRadarChart(ReportModel report) {
    final scoresMap = <String, double>{};
    for (final entry in report.scores.entries) {
      scoresMap[entry.key] = entry.value.score;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '能力维度',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Center(child: ScoreRadarChart(scores: scoresMap)),
          ],
        ),
      ),
    );
  }

  // -- Score breakdown -------------------------------------------------------

  Widget _buildScoreBreakdown(ReportModel report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '评分详情',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...report.scores.entries.map((entry) {
              final score = entry.value.score;
              final color = _scoreColor(score);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          score.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                    if (entry.value.comment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        entry.value.comment,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // -- Highlights ------------------------------------------------------------

  Widget _buildHighlights(ReportModel report) {
    if (report.highlights.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '亮点表现',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...report.highlights.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // -- Improvements ----------------------------------------------------------

  Widget _buildImprovements(ReportModel report) {
    if (report.improvements.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '改进建议',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...report.improvements.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // -- Dialogue replay -------------------------------------------------------

  Widget _buildDialogueReplay(ReportModel report) {
    if (report.dialogueAnnotations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '对话回放',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...report.dialogueAnnotations.map((annotation) {
              final isUser = annotation.role == 'user';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.brandOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isUser ? '我' : '客户',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isUser
                              ? AppColors.primary
                              : AppColors.brandOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Message content
                    Text(
                      annotation.content,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    // Feedback annotation
                    if (annotation.feedback != null &&
                        annotation.feedback!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.auto_awesome,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                annotation.feedback!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
