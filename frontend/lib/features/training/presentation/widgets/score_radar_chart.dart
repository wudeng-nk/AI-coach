import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ai_coach/core/theme/app_colors.dart';

const kRadarDimensions = [
  '开场破冰',
  '需求挖掘',
  '产品呈现',
  '异议处理',
  '促成成交',
  '沟通技巧',
];

class ScoreRadarChart extends StatelessWidget {
  final Map<String, double> scores;

  const ScoreRadarChart({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final rawScores = kRadarDimensions.map((dim) => scores[dim] ?? 0.0).toList();

    return SizedBox(
      height: 260,
      width: 260,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor: AppColors.primary.withValues(alpha: 0.2),
              borderColor: AppColors.primary,
              borderWidth: 2,
              entryRadius: 4,
              dataEntries: rawScores.map((s) => RadarEntry(value: s / 20)).toList(),
            ),
          ],
          radarBackgroundColor: Colors.transparent,
          radarBorderData: const BorderSide(color: Colors.transparent),
          titlePositionPercentageOffset: 0.2,
          getTitle: (index, _) {
            if (index < 0 || index >= kRadarDimensions.length) {
              return RadarChartTitle(text: '');
            }
            return RadarChartTitle(
              text: kRadarDimensions[index],
              positionPercentageOffset: 0.2,
            );
          },
          tickCount: 5,
          ticksTextStyle: const TextStyle(color: AppColors.divider, fontSize: 0),
          radarTouchData: RadarTouchData(),
        ),
      ),
    );
  }
}
