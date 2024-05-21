import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthService authService;
  late UserService userService;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    initFToast(context);
    authService = Provider.of<AuthService>(context, listen: false);
    userService = Provider.of<UserService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              authService.logout().then((_) {
                GoRouter.of(context).go("/auth/login");
              });
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 28.0,
            ),
          ),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _selectedImage == null
                ? FutureBuilder(
                    future: authService.getLoggedInUser(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasData) {
                        return IconButton(
                          onPressed: () => _showChoiceDialog(context),
                          icon: Stack(
                            children: [
                              CustomCircleAvatar(
                                radius: 95,
                                imageUrl:
                                    "$baseUrl/user/profilePicture?username=${(snapshot.data as LoggedUserInfo).username}",
                                name:
                                    (snapshot.data as LoggedUserInfo).firstName,
                              ),
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: IconButton(
                                    onPressed: () => _showChoiceDialog(context),
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  )
                : IconButton(
                    onPressed: () => _showChoiceDialog(context),
                    icon: Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: FileImage(_selectedImage!),
                          radius: 100,
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.green[700],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              onPressed: () => _updateProfilePicture(),
                              icon: const Icon(
                                Icons.check_rounded,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red[700],
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              onPressed: () =>
                                  setState(() => _selectedImage = null),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 40),
            FutureBuilder(
              future: authService.getLoggedInUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text(
                        "${(snapshot.data as LoggedUserInfo).firstName} ${(snapshot.data as LoggedUserInfo).lastName}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (snapshot.data as LoggedUserInfo).username,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        (snapshot.data as LoggedUserInfo).email,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Future _updateProfilePicture() async {
    final response =
        await userService.updateProfilePicture(_selectedImage!.path);
    if (response == null) {
      setState(() {
        _selectedImage = null;
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        showOKToast("Profile picture uploaded");
      });
      GoRouter.of(context).replace('/profile');
    } else {
      Future.delayed(const Duration(milliseconds: 100), () {
        showOKToast("Profile picture uploaded");
      });
    }
  }

  void _showChoiceDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Choose a source"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: const Text("Pick from Gallery"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(source: ImageSource.gallery);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: const Text("Take a picture"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(source: ImageSource.camera);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  Future _pickImage({required ImageSource source}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }
}
