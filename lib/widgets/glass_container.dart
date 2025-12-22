import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12,
    this.opacity = 0.20,
    this.padding = const .all(16),
    this.margin = const .all(0),
    this.borderRadius = const .all(.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          margin: margin,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withValues(alpha: opacity + 0.10),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
