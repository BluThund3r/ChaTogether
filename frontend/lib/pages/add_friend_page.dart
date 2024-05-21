import 'package:flutter/material.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  List<User> users = [];
  bool searched = false;
  bool loading = false;
  final TextEditingController searchController = TextEditingController();
  late UserService userService;
  final addedUsers = <String>{};
  late FriendService friendService;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    friendService = Provider.of<FriendService>(context, listen: false);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onClear() {
    setState(() {
      searched = false;
      users = [];
    });
  }

  void addFriend(String username) async {
    final response = await friendService.sendFriendRequest(username);
    if (response is String) {
      showErrorToast(response);
      return;
    }
    setState(() {
      addedUsers.add(username);
    });
  }

  void onSearch(String value) async {
    if (value.isEmpty || value.length < 3) {
      return;
    }

    setState(() {
      loading = true;
      searched = true;
    });

    final localUsers =
        await userService.getUsersNotRelated(searchController.text);
    if (localUsers is String) {
      showErrorToast(localUsers);
      setState(() {
        loading = false;
        searchController.clear();
        searched = false;
        users = [];
      });
      return;
    }

    setState(() {
      users = localUsers;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    initFToast(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Friend',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSearchBar(
                controller: searchController,
                onSubmit: onSearch,
                onClear: onClear,
              ),
              if (users.isEmpty && !loading && searched)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                      Text(
                        'No users found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              if (loading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              if (users.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            user.firstName[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${user.firstName} ${user.lastName}',
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
                        trailing: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: addedUsers.contains(user.username)
                              ? const ElevatedButton(
                                  onPressed: null,
                                  child: Text('Request Sent'),
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    addFriend(user.username);
                                  },
                                  child: const Text('Send Request'),
                                ),
                        ),
                      );
                    },
                  ),
                ),
              if (!loading && !searched && users.isEmpty)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                      Text(
                        'Search for a user',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'At least 3 characters',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
              const SizedBox(height: 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
