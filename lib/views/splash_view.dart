import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/views/home_tasks_view.dart';
import 'package:flowday/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Consumer<AuthController>(
              builder: (context, auth, _) {
                if (auth.isLoading) {
                  return const CircularProgressIndicator(color: Colors.white);
                }

                final taskController = context.read<TaskController>();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (auth.isAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            HomeTasksView(controller: taskController),
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
      ),
    );
  }
}
