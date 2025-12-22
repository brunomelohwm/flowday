import 'package:flutter/material.dart';

class AppColors {
  static const Color darkPurple = Color.fromARGB(255, 10, 0, 20);
  static const Color midPurple = Color.fromARGB(255, 14, 1, 43);
  static const Color neonPurple = Color.fromARGB(255, 36, 2, 59);
}

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: .topLeft,
    end: .bottomRight,
    colors: [AppColors.darkPurple, AppColors.midPurple, AppColors.neonPurple],
  );
}
