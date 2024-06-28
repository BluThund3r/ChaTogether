import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/components/user_details_bottom_sheet.dart';
import 'package:frontend/interfaces/user_details_for_admin.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  final TextEditingController searchController = TextEditingController();
  late AdminService adminService;
  late AuthService authService;
  List<UserDetailsForAdmin> users = [];
  List<UserDetailsForAdmin> displayedUsers = [];
  late int loggedInUserId;
  bool loaded = false;

  void fetchUserData() async {
    var users = await adminService.getUsers();

    if (users is String) {
      initFToast(context);
      showErrorToast("Failed to load users");
      return;
    }

    final loggedInUserId = (await authService.getLoggedInUser()).userId;
    if (users is List<UserDetailsForAdmin>) {
      setState(() {
        this.users = users;
        displayedUsers = users;
        loaded = true;
        this.loggedInUserId = loggedInUserId;
      });
    }
  }

  void handleSearch(String searchValue) {
    if (searchValue.isEmpty) {
      setState(() {
        displayedUsers = users;
      });
      return;
    }

    final searchResults = users.where((user) {
      final fullName =
          "${user.firstName.toLowerCase()} ${user.lastName.toLowerCase()}";
      return user.username.toLowerCase().contains(searchValue.toLowerCase()) ||
          fullName.contains(searchValue.toLowerCase());
    }).toList();

    setState(() {
      displayedUsers = searchResults;
    });
  }

  void handleClear() {
    searchController.clear();
    setState(() {
      displayedUsers = users;
    });
  }

  void toggleRole(int userId) {
    setState(() {
      for (var user in users) {
        if (user.id == userId) {
          user.isAppAdmin = !user.isAppAdmin;
        }
      }
    });
  }

  void handleUserTap(BuildContext context, UserDetailsForAdmin user) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return UserDetailsBottomSheet(
            user: user,
            isCurrentuser: user.id == loggedInUserId,
            toggleUserRole: toggleRole,
          );
        });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    adminService = Provider.of<AdminService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: loaded
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    CustomSearchBar(
                      controller: searchController,
                      onSubmit: handleSearch,
                      onClear: handleClear,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: displayedUsers.length,
                        itemBuilder: (context, index) {
                          final user = displayedUsers[index];
                          return GestureDetector(
                            onTap: () => handleUserTap(context, user),
                            child: ListTile(
                              leading: CustomCircleAvatarNoCache(
                                imageUrl:
                                    "$baseUrl/user/profilePicture?username=${user.username}",
                                name: user.firstName,
                              ),
                              title: Text(
                                "${user.firstName} ${user.lastName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                user.username,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: user.isAppAdmin
                                  ? const Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
