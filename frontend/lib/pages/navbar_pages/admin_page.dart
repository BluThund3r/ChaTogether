import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late AuthService authService;

  void checkAdmin() async {
    final isAdmin = await authService.checkAdmin();
    if (!isAdmin) {
      authService.logout().then((_) {
        GoRouter.of(context).go("/auth/login");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    checkAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.admin_panel_settings_rounded,
            size: 150,
            color: Colors.grey,
          ),
          const Text(
            'Admin Page',
            style: TextStyle(
              fontSize: 25,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            "See statistics regarding app users",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).push("/admin/statistics");
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            child: const Text("See Statistics"),
          ),
          const SizedBox(height: 50),
          const Text("See all users in the app and their information"),
          const SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).push("/admin/users");
            },
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
            child: const Text("See Users"),
          ),
        ],
      ),
    );
  }
}
