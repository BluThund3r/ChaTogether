import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    authService.logout();
    return const Scaffold(
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
