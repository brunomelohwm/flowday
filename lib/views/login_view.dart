import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/themes/app_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'FlowDay',
                  style: TextStyle(
                    fontSize: 32,
                    color: Color(0xFF212121),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Color(0xFF212121)),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Color(0xFF212121)),
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () {
                            auth.login(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );
                          },
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
