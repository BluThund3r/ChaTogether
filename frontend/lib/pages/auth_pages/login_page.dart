import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  late AuthService authService;
  String? _usernameOrEmail;
  String? _password;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
  }

  void onFormSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    setState(() => _loading = true);
    final errorMessage = await authService.login(_usernameOrEmail!, _password!);
    setState(() => _loading = false);
    if (errorMessage == null) {
      GoRouter.of(context).go('/');
    } else {
      showErrorToast(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    initFToast(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 125),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_circle_sharp, size: 150),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome back to ChaTogether',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Login to your account',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username or Email is required';
                        }
                        return null;
                      },
                      onSaved: (value) => _usernameOrEmail = value,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Username or Email',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          icon: Icon(_passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility),
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onFormSubmit,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                      ),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            backgroundColor: Colors.blueGrey,
                          )
                        : const Text('Log In', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text("Don't have an account?"),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/auth/register');
                            },
                            child: const Text('Create one now',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          const Text("Want to verify your email?"),
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/auth/verify-email');
                            },
                            child: const Text('Verify now',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
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
