import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/views/login_view.dart';
import 'package:flowday/views/main_shell_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:flowday/themes/app_colors.dart';

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
                return const CircularProgressIndicator(
                  color: AppColors.primary,
                );
              }

              if (auth.errorMessage != null && auth.currentUserId != null) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auth.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      TextButton(
                        onPressed: auth.retryLoadProfile,
                        child: const Text('Tentar carregar novamente'),
                      ),
                    ],
                  ),
                );
              }
              final taskController = context.read<TaskController>();

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (auth.isAuthenticated && auth.currentUserId != null) {
                  taskController.setUserId(auth.currentUserId!);

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MainShellView(taskController: taskController),
                      ),
                    );
                  }
                } else {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                  }
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
