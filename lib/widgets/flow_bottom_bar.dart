import 'package:flowday/widgets/glass_container.dart';
import 'package:flutter/material.dart';

class FlowBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FlowBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double barHeight = 60;
  static const double fabRadius = 28;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return SizedBox(
      height: barHeight + bottomInset,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ClipPath(
          clipper: FlowBarClipper(fabRadius: fabRadius),
          child: GlassContainer(
            child: Container(
              height: barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _item(Icons.home_outlined, 0),
                  _item(Icons.calendar_month_outlined, 1),
                  const SizedBox(width: 40),
                  _item(Icons.person_outlined, 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, int index) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        size: 22,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}

class FlowBarClipper extends CustomClipper<Path> {
  final double fabRadius;

  FlowBarClipper({required this.fabRadius});

  @override
  Path getClip(Size size) {
    final path = Path();

    final centerX = size.width / 2;
    final notchRadius = fabRadius + 4;
    const notchDepth = 18.0;
    const slope = 0.0;

    path.moveTo(0, slope);

    // canto esquerdo chanfrado
    path.lineTo(slope, 0);
    path.lineTo(centerX - notchRadius - 12, 0);

    // curva do encaixe do FAB
    path.quadraticBezierTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius + 4,
      notchDepth,
    );

    path.arcToPoint(
      Offset(centerX + notchRadius - 4, notchDepth),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.quadraticBezierTo(
      centerX + notchRadius,
      0,
      centerX + notchRadius + 12,
      0,
    );

    // canto direito chanfrado
    path.lineTo(size.width - slope, 0);
    path.lineTo(size.width, slope);

    // base
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
