import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ai_coach/core/theme/app_colors.dart';

const kRadarDimensions = [
  '共情力',
  '需求洞察',
  '产品思维',
  '谈判处理',
  '推进成交',
];

class ScoreRadarChart extends StatelessWidget {
  final Map<String, double> scores;
  final Map<String, double>? averageScores;

  const ScoreRadarChart({super.key, required this.scores, this.averageScores});

  @override
  Widget build(BuildContext context) {
    final rawScores = kRadarDimensions.map((dim) => scores[dim] ?? 0.0).toList();

    final dataSets = <RadarDataSet>[
      RadarDataSet(
        fillColor: const Color(0xFF2196F3).withValues(alpha: 0.15),
        borderColor: const Color(0xFF2196F3),
        borderWidth: 2,
        entryRadius: 4,
        dataEntries: rawScores.map((s) => RadarEntry(value: s / 20)).toList(),
      ),
    ];

    if (averageScores != null) {
      final avgRaw = kRadarDimensions.map((dim) => averageScores![dim] ?? 0.0).toList();
      dataSets.add(RadarDataSet(
        fillColor: Colors.grey.withValues(alpha: 0.05),
        borderColor: Colors.grey.withValues(alpha: 0.4),
        borderWidth: 1.5,
        entryRadius: 0,
        dataEntries: avgRaw.map((s) => RadarEntry(value: s / 20)).toList(),
      ));
    }

    return SizedBox(
      height: 260,
      width: 260,
      child: RadarChart(
        RadarChartData(
          dataSets: dataSets,
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
