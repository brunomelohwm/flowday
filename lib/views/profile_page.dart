import 'package:flowday/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthController>().logout();
          },
          child: const Text('Sair'),
        ),
      ),
    );
  }
}
