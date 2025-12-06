import 'package:flutter/material.dart';

class AppColors {
  static const Color darkPurple = Color(0xFF1A0034);
  static const Color midPurple = Color(0xFF3A0CA3);
  static const Color neonPurple = Color(0xFF7209B7);
}

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: .topLeft,
    end: .bottomRight,
    colors: [AppColors.darkPurple, AppColors.midPurple, AppColors.neonPurple],
  );
}
