import 'package:flutter/material.dart';
import 'package:ai_coach/core/theme/app_colors.dart';
import 'package:ai_coach/shared/widgets/gradient_avatar.dart';

class FloatingTip extends StatefulWidget {
  final String message;
  final bool hasBadge;
  final int? badgeCount;

  const FloatingTip({
    super.key,
    required this.message,
    this.hasBadge = false,
    this.badgeCount,
  });

  @override
  State<FloatingTip> createState() => _FloatingTipState();
}

class _FloatingTipState extends State<FloatingTip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 80,
      child: AnimatedBuilder(
        animation: _floatController,
        builder: (context, child) {
          final offset = _floatController.value * 8;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () => setState(() => _showBubble = !_showBubble),
          child: SizedBox(
            width: 280,
            height: 70,
            child: Stack(
              children: [
                // 气泡
                if (_showBubble)
                  Positioned(
                    right: 64,
                    top: 0,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message,
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.5),
                      ),
                    ),
                  ),
                // 头像
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GradientAvatar.squirrel(size: 56),
                      if (widget.hasBadge && widget.badgeCount != null)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${widget.badgeCount}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
