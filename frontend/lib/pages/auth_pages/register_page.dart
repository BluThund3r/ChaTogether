import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/regex_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final RegexValidator _regexValidator = RegexValidator();
  final TextEditingController _passwordController = TextEditingController();
  late AuthService authService;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _username;
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _password;
  String? _confirmPassword;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
  }

  void onFormSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    var info = {
      'username': _username!,
      'firstName': _firstName!,
      'lastName': _lastName!,
      'email': _email!,
      'password': _password!,
      "confirmPassword": _confirmPassword!,
    };

    setState(() => _loading = true);
    final errorMessage = await authService.register(info);
    setState(() => _loading = false);

    if (errorMessage == null) {
      showOKToast('Account created successfully');
      GoRouter.of(context).go('/auth/verify-email');
    } else {
      showErrorToast(errorMessage);
    }
  }

  String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Please enter a username';
    }
    return _regexValidator.validateUsername(username)
        ? null
        : 'Invalid username';
  }

  String? validateFirstName(String? firstName) {
    if (firstName == null || firstName.isEmpty) {
      return 'Please enter your first name';
    }
    return _regexValidator.validateName(firstName)
        ? null
        : 'Invalid first name';
  }

  String? validateLastName(String? lastName) {
    if (lastName == null || lastName.isEmpty) {
      return 'Please enter your last name';
    }
    return _regexValidator.validateName(lastName) ? null : 'Invalid last name';
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    }
    return _regexValidator.validateEmail(email) ? null : 'Invalid email';
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    return _regexValidator.validatePassword(password)
        ? null
        : 'Invalid password';
  }

  String? validateConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    initFToast(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // padding: const EdgeInsets.only(top: 125),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // const SizedBox(height: 40),
                const Icon(Icons.person_add_sharp, size: 150),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to ChaTogether',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Create an account to continue',
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          onSaved: (value) => _username = value,
                          validator: validateUsername,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            suffixIcon: const Tooltip(
                              message:
                                  '''Username must:\n - contain 4-20 characters\n - start with a letter or underscore\n - only contain letters, numbers, dots, and underscores''',
                              child: Icon(Icons.info),
                            ),
                            labelText: 'Username',
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
                          onSaved: (value) => _firstName = value,
                          validator: validateFirstName,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'First Name',
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
                          onSaved: (value) => _lastName = value,
                          validator: validateLastName,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Last Name',
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
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) => _email = value,
                          validator: validateEmail,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Email',
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
                          obscureText: !_passwordVisible,
                          onSaved: (value) => _password = value,
                          controller: _passwordController,
                          validator: validatePassword,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Password',
                            suffixIcon: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Tooltip(
                                  message:
                                      '''Password must contain at least:\n - 8 characters\n - 1 uppercase letter\n - 1 lowercase letter\n - 1 number\n - 1 special character from the following set:\n    !?()*\[\]+\-_.,:;<=>@'"''',
                                  child: Icon(Icons.info),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                  icon: Icon(_passwordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ],
                            ),
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
                          obscureText: !_passwordVisible,
                          onSaved: (value) => _confirmPassword = value,
                          validator: validateConfirmPassword,
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
                            labelText: 'Confirm Password',
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
                            : const Text(
                                'Register',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    GoRouter.of(context).go('/auth/login');
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontSize: 16),
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
