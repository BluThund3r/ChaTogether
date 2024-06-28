import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/regex_validator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfileDetails extends StatefulWidget {
  final LoggedUserInfo userInfo;
  const EditProfileDetails({super.key, required this.userInfo});

  @override
  State<EditProfileDetails> createState() => _EditProfileDetailsState();
}

class _EditProfileDetailsState extends State<EditProfileDetails> {
  String? username = "";
  String? email = "";
  String? firstName = "";
  String? lastName = "";
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final RegexValidator _regexValidator = RegexValidator();
  final _formKey = GlobalKey<FormState>();
  late UserService userService;
  late AuthService authService;

  @override
  void initState() {
    super.initState();
    username = widget.userInfo.username;
    email = widget.userInfo.email;
    firstName = widget.userInfo.firstName;
    lastName = widget.userInfo.lastName;
    usernameController.text = username!;
    emailController.text = email!;
    firstNameController.text = firstName!;
    lastNameController.text = lastName!;
    userService = Provider.of<UserService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
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

  void submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final initialUsername = widget.userInfo.username;
    final initialEmail = widget.userInfo.email;
    final initialFirstName = widget.userInfo.firstName;
    final initialLastName = widget.userInfo.lastName;

    if (initialEmail == email &&
        initialUsername == username &&
        initialFirstName == firstName &&
        initialLastName == lastName) {
      initFToast(context);
      showInfoToast("No changes made");
      return;
    }

    var updatedUserInfo = {
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };

    final response = await userService.updateUserInfo(updatedUserInfo);

    if (response != null) {
      initFToast(context);
      showErrorToast(response);
    } else {
      initFToast(context);
      showOKToast("Profile details updated");
      authService.logout().then((_) {
        GoRouter.of(context).go("/auth/login");
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: usernameController,
                onSaved: (value) => username = value,
                validator: validateUsername,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Tooltip(
                    message:
                        '''Username must:\n - contain 4-20 characters\n - start with a letter or underscore\n - only contain letters, numbers, dots, and underscores''',
                    child: Icon(
                      Icons.info,
                      size: 25,
                    ),
                  ),
                  labelText: 'Username',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => email = value,
                validator: validateEmail,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: firstNameController,
                onSaved: (value) => firstName = value,
                validator: validateFirstName,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: 'First Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: lastNameController,
                onSaved: (value) => lastName = value,
                validator: validateLastName,
                decoration: InputDecoration(
                  isDense: true,
                  border: const OutlineInputBorder(),
                  labelText: 'Last Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 30),
              Align(
                child: ElevatedButton(
                  onPressed: () => submitForm(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 62, 112, 173)),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
