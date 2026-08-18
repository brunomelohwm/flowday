import 'package:flowday/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FlowDayLogo extends StatelessWidget {
  final double iconSize;
  final double fontSize;

  const FlowDayLogo({
    super.key,
    this.iconSize = 44,
    this.fontSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'FlowDay',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(iconSize * .3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.done_all_rounded,
              color: AppColors.background,
              size: iconSize * .58,
            ),
          ),
          const SizedBox(width: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Flow',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.8,
                  ),
                ),
                TextSpan(
                  text: 'Day',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
