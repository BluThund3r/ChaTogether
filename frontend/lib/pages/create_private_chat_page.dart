import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';

class CreatePrivateChatPage extends StatefulWidget {
  const CreatePrivateChatPage({super.key});

  @override
  State<CreatePrivateChatPage> createState() => _CreatePrivateChatPageState();
}

class _CreatePrivateChatPageState extends State<CreatePrivateChatPage> {
  List<User> users = [];
  List<User> displayedUsers = [];
  bool loading = true;
  late ChatRoomService _chatRoomService;
  int selectedIndex = -1;
  final TextEditingController _searchController = TextEditingController();

  void fetchData() async {
    final response = await _chatRoomService.getFriendsWithNoPrivateChat();
    if (response is! List<User> && mounted) {
      initFToast(context);
      showErrorToast(response);
      setState(() => loading = false);
      return;
    } else if (mounted) {
      setState(() {
        users = response;
        displayedUsers = response;
        loading = false;
      });
    }
  }

  void onSearchClear() {
    setState(() {
      _searchController.clear();
      displayedUsers = users;
    });
  }

  void onSearchSubmit(String searchValue) {
    print("Search value: $searchValue");

    if (searchValue.isEmpty) {
      setState(() {
        displayedUsers = users;
      });
      return;
    }

    setState(() {
      displayedUsers = users
          .where((user) =>
              user.username.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
    });

    print("Displayed users for search: $displayedUsers");
  }

  void createPrivateChat() async {
    if (selectedIndex < 0) {
      initFToast(context);
      showErrorToast("You have to select a user");
      return;
    }

    final response =
        await _chatRoomService.createPrivateChat(users[selectedIndex].username);
    if (response is String && mounted) {
      initFToast(context);
      showErrorToast(response);
      return;
    }

    if (mounted) {
      initFToast(context);
      showOKToast("Private chat created successfully");
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showConfirmDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
              'Are you sure you want to create private chat with ${users[selectedIndex].username}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                createPrivateChat();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Private Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: selectedIndex >= 0
          ? FloatingActionButton(
              onPressed: () => _showConfirmDialog(context),
              child: const SizedBox(
                height: 100,
                width: 100,
                child: Icon(Icons.check_rounded),
              ),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: loading || displayedUsers.isEmpty
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            CustomSearchBar(
              controller: _searchController,
              onSubmit: onSearchSubmit,
              onClear: onSearchClear,
            ),
            if (!loading && displayedUsers.isNotEmpty)
              const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : displayedUsers.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_rounded,
                              size: 150,
                              color: Colors.grey,
                            ),
                            Text(
                              "No friends found",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 80),
                          ],
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            final user = displayedUsers[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: selectedIndex == index
                                      ? const Color.fromARGB(255, 2, 90, 125)
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading: CustomCircleAvatarNoCache(
                                      radius: 25,
                                      imageUrl:
                                          '$baseUrl/user/profilePicture?username=${user.username}',
                                      name: user.firstName,
                                    ),
                                    title: Text(user.username),
                                    onTap: () =>
                                        setState(() => selectedIndex = index),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: displayedUsers.length,
                        ),
                      ),
            if (loading || displayedUsers.isEmpty) const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}
