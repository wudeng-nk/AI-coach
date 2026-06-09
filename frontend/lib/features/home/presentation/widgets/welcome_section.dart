import 'package:flutter/material.dart';
import 'package:ai_coach/shared/widgets/squirrel_avatar.dart';

class WelcomeBanner extends StatelessWidget {
  final String userName;
  final int consecutiveDays;

  const WelcomeBanner({
    super.key,
    required this.userName,
    required this.consecutiveDays,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 32),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 松鼠头像 - 大图标占满白色矩形高度
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: const SquirrelAvatar(size: 110),
                ),
                // 文字内容
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '欢迎回来，$userName销冠！',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                            children: [
                              TextSpan(text: '本周共情力提升 '),
                              TextSpan(
                                text: '12%',
                                style: TextStyle(
                                  color: Color(0xFFF1C40F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
