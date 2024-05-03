import 'package:flutter/material.dart';
import 'package:frontend/components/resend_verification_code_modal.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MailVerificationPage extends StatefulWidget {
  const MailVerificationPage({super.key});

  @override
  State<MailVerificationPage> createState() => _MailVerificationPageState();
}

class _MailVerificationPageState extends State<MailVerificationPage> {
  late AuthService authService;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    initFToast(context);
  }

  String? _verificationCode;
  final _formKey = GlobalKey<FormState>();

  String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Verification code is required';
    }
    if (value.length != 10) {
      return 'Verification code must be 10 characters long';
    }
    return null;
  }

  void handleResendButton() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => const Scaffold(
        body: ResendVerificationCodeModal(),
      ),
    );
  }

  void submitVerificationCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    setState(() => _loading = true);
    final errorMessage = await authService.verifyEmail(_verificationCode!);
    setState(() => _loading = false);
    if (errorMessage == null) {
      GoRouter.of(context).go('/auth/login');
      showOKToast('Email verified successfully');
    } else {
      showErrorToast(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 125),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Icon(Icons.email_sharp, size: 150),
                const SizedBox(height: 20),
                const Text(
                  'Verify your email address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Paste the verification code sent to your email',
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: SizedBox(
                    width: 300,
                    child: TextFormField(
                      onSaved: (value) => _verificationCode = value,
                      validator: validateVerificationCode,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Verification Code',
                        labelStyle: const TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitVerificationCode,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    ),
                  ),
                  child: _loading
                      ? CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                          backgroundColor: Colors.blueGrey,
                        )
                      : const Text('Verify', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text("Already verified?"),
                        TextButton(
                          onPressed: () {
                            GoRouter.of(context).go('/auth/login');
                          },
                          child: const Text('Back to Login',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text("Lost the code?"),
                        TextButton(
                          onPressed: handleResendButton,
                          child: const Text('Resend it',
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
    );
  }
}
