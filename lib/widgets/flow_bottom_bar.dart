import 'package:flowday/themes/app_colors.dart';
import 'package:flutter/material.dart';

class FlowBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FlowBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double barHeight = 64;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: barHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SizedBox(
        height: barHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _item(Icons.home_outlined, 0),
            _item(Icons.calendar_month_outlined, 1),
            _item(Icons.person_outlined, 2),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, int index) {
    final isActive = currentIndex == index;

    return Semantics(
      button: true,
      selected: isActive,
      child: InkResponse(
        onTap: () => onTap(index),
        radius: 26,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
