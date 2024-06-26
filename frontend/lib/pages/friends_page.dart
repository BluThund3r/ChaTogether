import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<User> allFriends = [];
  List<User> displayedFriends = [];
  late FriendService friendService;

  @override
  void initState() {
    super.initState();
    friendService = Provider.of<FriendService>(context, listen: false);
    fetchFriends();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchFriends() async {
    if (mounted) {
      setState(() => loading = true);
    }

    final friends = await friendService.fetchFriends();

    if (friends is! String) {
      if (mounted) {
        setState(() {
          allFriends = friends;
          displayedFriends = friends;
          loading = false;
        });
      }
    } else {
      if (mounted) {
        showErrorToast(friends);
        setState(() => loading = false);
      }
    }
  }

  void onClear() {
    setState(() => displayedFriends = allFriends);
  }

  void handleSearch(String searchString) async {
    if (searchString.isEmpty) {
      setState(() => displayedFriends = allFriends);
      return;
    }

    final searchResults = allFriends
        .where((friend) =>
            friend.username
                .toLowerCase()
                .contains(searchString.toLowerCase()) ||
            ('${friend.firstName} ${friend.lastName}')
                .toLowerCase()
                .contains(searchString.toLowerCase()))
        .toList();

    setState(() => displayedFriends = searchResults);
  }

  void unfriend(String username) async {
    final response = await friendService.unfriend(username);

    if (response is String) {
      showErrorToast(response);
      return;
    }

    final updatedFriends =
        allFriends.where((friend) => friend.username != username).toList();
    setState(() {
      allFriends = updatedFriends;
      displayedFriends = updatedFriends;
    });

    showOKToast("Friend removed");
  }

  void showRemoveDialog(BuildContext context, String usernameToRemove) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Remove Friend"),
            content: const Text(
                "Removing a friend will permanently delete your private chat with them. Are you sure you want to remove them?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  unfriend(usernameToRemove);
                },
                child: const Text("Remove"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    initFToast(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Friends',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        actions: allFriends.isNotEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.group_rounded),
                      Text(
                        ' ${allFriends.length}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                )
              ]
            : null,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomSearchBar(
                  controller: searchController,
                  onSubmit: (value) => handleSearch(value),
                  onClear: onClear),
              if (loading) const CircularProgressIndicator(),
              if (!loading &&
                  displayedFriends.isEmpty &&
                  displayedFriends.length != allFriends.length)
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
                        'No friends found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!loading && allFriends.isEmpty)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                      Text(
                        "You don't have any friends yet",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Send friend requests to start making friends",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!loading && displayedFriends.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedFriends.length,
                    itemBuilder: (context, index) {
                      final friend = displayedFriends[index];
                      return ListTile(
                        leading: CustomCircleAvatarNoCache(
                          imageUrl:
                              "$baseUrl/user/profilePicture?username=${friend.username}",
                          name: friend.firstName,
                          radius: 25,
                        ),
                        title: Text(
                          '${friend.firstName} ${friend.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(friend.username),
                        trailing: ElevatedButton(
                          child: const Text("Remove"),
                          onPressed: () =>
                              showRemoveDialog(context, friend.username),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
