import 'package:flowday/controllers/auth_controller.dart';
import 'package:flowday/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Color(0xFF212121))),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthController>().logout();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginView()),
            );
          },
          child: const Text('Sair'),
        ),
      ),
    );
  }
}
