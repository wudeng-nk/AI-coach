import 'package:flutter/material.dart';

import 'package:ai_coach/core/theme/app_colors.dart';

class DataPage extends StatelessWidget {
  const DataPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('数据'),
        backgroundColor: AppColors.surface,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart, size: 48, color: AppColors.textHint),
            SizedBox(height: 12),
            Text(
              '数据功能开发中…',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }
}
