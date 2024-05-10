import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/regex_validator.dart';
import 'package:provider/provider.dart';

class ResendVerificationCodeModal extends StatefulWidget {
  const ResendVerificationCodeModal({super.key});

  @override
  State<ResendVerificationCodeModal> createState() =>
      _ResendVerificationCodeModalState();
}

class _ResendVerificationCodeModalState
    extends State<ResendVerificationCodeModal> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  int trialsLeft = -1; // the user hasn't submitted their email yet
  final RegexValidator _regexValidator = RegexValidator();
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    initFToast(context);
    authService = Provider.of<AuthService>(context, listen: false);
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    }
    return _regexValidator.validateEmail(email) ? null : 'Invalid email';
  }

  void handleEmailSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    var trialsLeftResponse =
        await authService.getEmailVerificationTrialsLeft(email!);
    if (trialsLeftResponse is! int) {
      showErrorToast(trialsLeftResponse);
      return;
    }
    setState(() {
      trialsLeft = trialsLeftResponse;
    });
  }

  void resendConfirmationCode() async {
    var response = await authService.resendVerificationCode(email!);
    if (response == null) {
      showOKToast('Verification code resent');
    } else {
      showErrorToast(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Enter your email address'),
                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            enabled: trialsLeft < 0,
                            onSaved: (value) => email = value,
                            validator: validateEmail,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: 'Email',
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 20), // Add this line
                          ElevatedButton(
                            onPressed:
                                trialsLeft >= 0 ? null : handleEmailSubmit,
                            child: const Text(
                              'Submit',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (trialsLeft > 0)
                      Column(
                        children: [
                          Text(
                            trialsLeft == 2
                                ? 'You have $trialsLeft trials left'
                                : 'You only have 1 trial left',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: resendConfirmationCode,
                            child: const Text('Confirm Resend'),
                          ),
                        ],
                      ),
                    if (trialsLeft < 0)
                      const Text(
                        'Submit your email \n to get the number of trials left',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    if (trialsLeft == 0)
                      const Text(
                        'You have no trials left',
                        style:
                            TextStyle(color: Color.fromARGB(255, 193, 32, 21)),
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
