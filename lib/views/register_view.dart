import 'package:email_validator/email_validator.dart';
import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/controllers/task_controller.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flowday/views/login_view.dart';
import 'package:flowday/views/main_shell_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:flowday/themes/app_colors.dart';
import 'package:flowday/widgets/flowday_logo.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final taskController = context.read<TaskController>();

    final registered = await auth.register(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      name: nameController.text.trim(),
      lastName: lastNameController.text.trim(),
    );

    if (!mounted) return;

    if (!registered) {
      return;
    }

    taskController.setUserId(auth.currentUserId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Conta criada com sucesso.')));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainShellView(taskController: taskController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const FlowDayLogo(),
                  const SizedBox(height: 8),
                  const Text(
                    'Criar nova conta',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome é obrigatório';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: lastNameController,
                    keyboardType: TextInputType.name,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Sobrenome'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Sobrenome é obrigatório';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email é obrigatório';
                      }
                      if (!EmailValidator.validate(value)) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Senha é obrigatória';
                      }
                      if (value.length < 6) {
                        return 'Senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Confirmar Senha',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirmação de senha é obrigatória';
                      }
                      if (value != passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthController>(
                    builder: (context, auth, _) {
                      final error = auth.errorMessage;
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          child: ListTile(
                            leading: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                            ),
                            title: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),
                            trailing: IconButton(
                              tooltip: 'Fechar mensagem',
                              onPressed: auth.clearError,
                              icon: const Icon(Icons.close, color: Colors.red),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleRegister,
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Criar Conta'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginView(),
                              ),
                            );
                          },
                    child: const Text(
                      'Já tem uma conta? Entrar',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
