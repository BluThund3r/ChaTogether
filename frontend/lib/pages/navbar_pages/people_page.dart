import 'package:flutter/material.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/friend_request.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  bool loaded = true;
  List<FriendRequest> receivedRequests = [];
  List<FriendRequest> sentRequests = [];
  late FriendService friendService;

  @override
  void initState() {
    super.initState();
    initFToast(context);
    friendService = Provider.of<FriendService>(context, listen: false);
    fetchData();
  }

  void fetchData() async {
    if (mounted) {
      setState(() {
        loaded = false;
      });
    }
    final received = await friendService.fetchReceivedFriendRequests();
    final sent = await friendService.fetchSentFriendRequests();

    if (received is List<FriendRequest> && sent is List<FriendRequest>) {
      if (mounted) {
        setState(() {
          receivedRequests = received;
          sentRequests = sent;
          loaded = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          loaded = false;
          showErrorToast(received is String ? received : sent);
        });
      }
    }
  }

  void cancelRequest(String receiverUsername) async {
    final response = await friendService.cancelFriendRequest(receiverUsername);
    if (response == null) {
      setState(() {
        sentRequests.removeWhere(
            (element) => element.receiver.username == receiverUsername);
      });
      showOKToast("Request cancelled");
    } else {
      showErrorToast(response);
    }
  }

  void acceptRequest(String senderUsername) async {
    final response = await friendService.acceptFriendRequest(senderUsername);
    if (response == null) {
      setState(() {
        receivedRequests.removeWhere(
            (element) => element.sender.username == senderUsername);
      });
      showOKToast("Request accepted");
    } else {
      showErrorToast(response);
    }
  }

  void rejectRequest(String senderUsername) async {
    final response = await friendService.rejectFriendRequest(senderUsername);
    if (response == null) {
      setState(() {
        receivedRequests.removeWhere(
            (element) => element.sender.username == senderUsername);
      });
      showOKToast("Request rejected");
    } else {
      showErrorToast(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loaded
        ? SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).push('/people/friends');
                          },
                          child: const Text('Friends'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).push('/people/blocked');
                          },
                          child: const Text('Blocked users'),
                        ),
                      ),
                    ),
                  ],
                ),
                if (receivedRequests.isEmpty && sentRequests.isEmpty)
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nothing new here",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                            "Click on the plus button to send friend requests"),
                      ],
                    ),
                  ),
                if (receivedRequests.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Received Friend Requests",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            height: 5,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: receivedRequests.length,
                              itemBuilder: (context, index) {
                                final request = receivedRequests[index];
                                return ListTile(
                                  title: Text(
                                      "${request.sender.firstName} ${request.sender.lastName}"),
                                  subtitle: Text(request.sender.username),
                                  leading: const Icon(Icons.person),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => acceptRequest(
                                            request.sender.username),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => rejectRequest(
                                            request.sender.username),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (sentRequests.isNotEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sent Friend Requests",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            height: 5,
                            thickness: 2,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sentRequests.length,
                              itemBuilder: (context, index) {
                                final request = sentRequests[index];
                                return ListTile(
                                  title: Text(
                                      "${request.receiver.firstName} ${request.receiver.lastName}"),
                                  subtitle: Text(request.receiver.username),
                                  leading: const Icon(Icons.person),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => cancelRequest(
                                            request.receiver.username),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 60)
              ],
            ),
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}
