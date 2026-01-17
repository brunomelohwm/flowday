import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/views/login_view.dart';
import 'package:flowday/views/main_shell_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Consumer<AuthController>(
            builder: (context, auth, _) {
              if (auth.isLoading) {
                return const CircularProgressIndicator(color: Color(0xFF212121));
              }

                final taskController = context.read<TaskController>();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (auth.isAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MainShellView(taskController: taskController),
                      ),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                  }
                });

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
