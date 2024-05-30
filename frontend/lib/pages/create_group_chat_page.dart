import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/custom_search_bar.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';

class GroupChatCreateDetails extends StatefulWidget {
  final List<User> selectedUsers;
  const GroupChatCreateDetails({super.key, required this.selectedUsers});

  @override
  State<GroupChatCreateDetails> createState() => _GroupChatCreateDetailsState();
}

class _GroupChatCreateDetailsState extends State<GroupChatCreateDetails> {
  final TextEditingController _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(height: 50),
          const Row(
            children: [
              Text(
                'Enter a group name',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a group name';
                }
                // Check if the string starts with a letter
                if (!value.startsWith(RegExp(r'[a-zA-Z0-9]'))) {
                  return 'Group name must start with a letter or digit';
                }
                // Check if the string contains only the allowed characters
                if (!value.contains(RegExp(r'^[a-zA-Z0-9_ ]*$'))) {
                  return 'Group name can only contain letters, digits, spaces, and underscores';
                }
                // Check if the string is less than 50 characters
                if (value.length > 50) {
                  return 'Group name must be less than 50 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${widget.selectedUsers.length}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.people_rounded),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final user = widget.selectedUsers[index];
                final imageUrl =
                    '$baseUrl/user/profilePicture?username=${user.username}';
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      CustomCircleAvatarNoCache(
                        name: user.firstName,
                        imageUrl: imageUrl,
                        radius: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(user.username),
                    ],
                  ),
                );
              },
              itemCount: widget.selectedUsers.length,
            ),
          ),
          ElevatedButton(
            onPressed: () => _createGroupChat(context),
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 20,
                ),
              ),
            ),
            child: const Text(
              'Create Group Chat',
              style: TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  _createGroupChat(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final response = await Provider.of<ChatRoomService>(context, listen: false)
        .createGroupChat(
      widget.selectedUsers.map((user) => user.username).toList(),
      _groupNameController.text,
    );
    if (response is String) {
      initFToast(context);
      showErrorToast(response);
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    initFToast(context);
    showOKToast('Group chat created successfully');
  }
}

class CreateGroupChatPage extends StatefulWidget {
  const CreateGroupChatPage({super.key});

  @override
  State<CreateGroupChatPage> createState() => _CreateGroupChatPageState();
}

class _CreateGroupChatPageState extends State<CreateGroupChatPage> {
  List<User> users = [];
  List<User> displayedUsers = [];
  bool loading = true;
  late FriendService _friendService;
  final TextEditingController _searchController = TextEditingController();
  late ChatRoomService _chatRoomService;
  Set<User> _selectedUsers = {};

  void fetchData() async {
    final response = await _friendService.fetchFriends();
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

  bool isUserSelected(User user) {
    return _selectedUsers.contains(user);
  }

  void onSearchClear() {
    setState(() {
      _searchController.clear();
      displayedUsers = users;
    });
  }

  void onSearchSubmit(String searchValue) {
    if (searchValue.isEmpty) {
      setState(() {
        displayedUsers = users;
      });
      return;
    }

    setState(() {
      displayedUsers = users
          .where((user) =>
              user.username.toLowerCase().contains(searchValue.toLowerCase()) ||
              ("${user.firstName.toLowerCase()} ${user.lastName.toLowerCase()}")
                  .contains(searchValue.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _friendService = Provider.of<FriendService>(context, listen: false);
    _chatRoomService = Provider.of<ChatRoomService>(context, listen: false);
    fetchData();
  }

  void _showInformationModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => GroupChatCreateDetails(
        selectedUsers: _selectedUsers.toList(),
      ),
    );
  }

  void _toggleSelectUser(User user) {
    if (_selectedUsers.contains(user)) {
      setState(() => _selectedUsers.remove(user));
    } else {
      setState(() => _selectedUsers.add(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Group Chat',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: _selectedUsers.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showInformationModal(),
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
                            final user = users[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: isUserSelected(user)
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
                                    onTap: () => setState(
                                      () => _toggleSelectUser(user),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: users.length,
                        ),
                      ),
            if (loading || displayedUsers.isEmpty) const SizedBox(height: 1),
          ],
        ),
      ),
    );
  }
}
