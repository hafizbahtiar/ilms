import 'package:flutter/material.dart';
import 'package:ilms/features/auth/domain/entities/auth_user.dart';

class AuthHomePage extends StatelessWidget {
  const AuthHomePage({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, ${user.name}'),
            const SizedBox(height: 8),
            Text(user.email),
          ],
        ),
      ),
    );
  }
}
