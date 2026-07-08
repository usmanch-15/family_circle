import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BadgeWidget extends StatelessWidget {
  final Widget child;
  final int count;
  final bool showBadge;
  final Color badgeColor;

  const BadgeWidget({
    super.key,
    required this.child,
    this.count = 0,
    this.showBadge = true,
    this.badgeColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge || count == 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4, right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// Dot badge (no number)
class DotBadge extends StatelessWidget {
  final Widget child;
  final bool show;
  final Color color;

  const DotBadge({
    super.key,
    required this.child,
    this.show = true,
    this.color = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -2, right: -2,
          child: Container(
            width: 10, height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}