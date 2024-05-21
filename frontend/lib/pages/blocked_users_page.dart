import 'package:flutter/material.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:provider/provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final TextEditingController searchController = TextEditingController();
  bool loading = false;
  List<User> allBlockedUsers = [];
  List<User> displayedBlockedUsers = [];
  late FriendService friendService;

  @override
  void initState() {
    super.initState();
    friendService = Provider.of<FriendService>(context, listen: false);
    fetchBlockedUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchBlockedUsers() async {
    if (mounted) {
      setState(() => loading = true);
    }

    final blockedUsers = await friendService.fetchBlockedUsers();

    if (blockedUsers is! String) {
      if (mounted) {
        setState(() {
          allBlockedUsers = blockedUsers;
          displayedBlockedUsers = blockedUsers;
          loading = false;
        });
      }
    } else {
      if (mounted) {
        showErrorToast(blockedUsers);
        setState(() => loading = false);
      }
    }
  }

  void onClear() {
    setState(() => displayedBlockedUsers = allBlockedUsers);
  }

  void handleSearch(String searchString) async {
    if (searchString.isEmpty) {
      setState(() => displayedBlockedUsers = allBlockedUsers);
      return;
    }

    final searchResults = allBlockedUsers
        .where((blockedUser) =>
            blockedUser.username
                .toLowerCase()
                .contains(searchString.toLowerCase()) ||
            ('${blockedUser.firstName} ${blockedUser.lastName}')
                .toLowerCase()
                .contains(searchString.toLowerCase()))
        .toList();

    setState(() => displayedBlockedUsers = searchResults);
  }

  void unblock(String username) async {
    final response = await friendService.unblockUser(username);

    if (response is String) {
      showErrorToast(response);
      return;
    }

    final updatedBlockedUsers =
        allBlockedUsers.where((friend) => friend.username != username).toList();
    setState(() {
      allBlockedUsers = updatedBlockedUsers;
      displayedBlockedUsers = updatedBlockedUsers;
    });

    showOKToast("User unblocked");
  }

  @override
  Widget build(BuildContext context) {
    initFToast(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Blocked Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        actions: allBlockedUsers.isNotEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block_rounded),
                      Text(
                        ' ${allBlockedUsers.length}',
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
                  displayedBlockedUsers.isEmpty &&
                  displayedBlockedUsers.length != allBlockedUsers.length)
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
                        'No blocked users found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!loading && allBlockedUsers.isEmpty)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_off_rounded,
                        size: 100,
                        color: Colors.grey,
                      ),
                      Text(
                        "You haven't blocked anyone yet",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Hope you don't have to",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              if (!loading && displayedBlockedUsers.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: displayedBlockedUsers.length,
                    itemBuilder: (context, index) {
                      final blockedUser = displayedBlockedUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            blockedUser.firstName[0],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          '${blockedUser.firstName} ${blockedUser.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(blockedUser.username),
                        trailing: ElevatedButton(
                          child: const Text('Unblock'),
                          onPressed: () => unblock(blockedUser.username),
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
