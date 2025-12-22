import 'package:flutter/material.dart';

class Diagonal extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(0, 0)
    ..lineTo(s.width, 0)
    ..lineTo(s.width, s.height - 12)
    ..lineTo(0, s.height)
    ..close();
  @override
  bool shouldReclip(c) => false;
}
