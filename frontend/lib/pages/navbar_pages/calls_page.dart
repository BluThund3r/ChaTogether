import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/call_details.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/call_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  late CallService callService;
  late AuthService authService;
  List<CallDetails> calls = [];
  bool loading = true;
  late LoggedUserInfo loggedUserInfo;

  void fetchCallsAndLoggedUser() async {
    loggedUserInfo = await authService.getLoggedInUser();

    final response = await callService.getMyCalls();
    if (response is String) {
      initFToast(context);
      showErrorToast(response);
      return;
    }

    setState(() {
      calls = response;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    callService = Provider.of<CallService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    fetchCallsAndLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : calls.isEmpty
            ? SizedBox(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_disabled_rounded,
                          size: 150, color: Colors.grey[500]),
                      const SizedBox(height: 20),
                      Text(
                        "No calls found",
                        style: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                    ]),
              )
            : Expanded(
                child: ListView.separated(
                  itemCount: calls.length,
                  itemBuilder: (context, index) {
                    final call = calls[index];
                    final avatarImageUrl = call.isPrivateChat
                        ? "$baseUrl/user/profilePicture?username=${call.pictureString}"
                        : "$baseUrl/chatRoom/groupPicture?chatRoomId=${call.pictureString}";
                    final timeDifference =
                        call.endTime.difference(call.startTime);
                    final timeDiffHours = timeDifference.inHours;
                    final timeDiffMinutes =
                        timeDifference.inMinutes.remainder(60);
                    final timeDiffSeconds =
                        timeDifference.inSeconds.remainder(60);
                    final timeDiffString = timeDiffHours > 0
                        ? "${timeDiffHours}h ${timeDiffMinutes}m ${timeDiffSeconds}s"
                        : timeDiffMinutes > 0
                            ? "${timeDiffMinutes}m ${timeDiffSeconds}s"
                            : "${timeDiffSeconds}s";
                    final startTimeString =
                        DateFormat("dd/MM/yy HH:mm").format(call.startTime);
                    final userParticipated =
                        call.userIds.contains(loggedUserInfo.userId);

                    return ListTile(
                      leading: CustomCircleAvatarNoCache(
                        imageUrl: avatarImageUrl,
                        isGroupConversation: !call.isPrivateChat,
                        name: call.roomName,
                      ),
                      title: Text(call.roomName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(call.isPrivateChat
                              ? "Private call,"
                              : "Group call,"),
                          const SizedBox(width: 5),
                          Text(timeDiffString)
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (userParticipated)
                            const Icon(
                              Icons.phone_rounded,
                              color: Colors.green,
                            ),
                          if (!userParticipated)
                            const Icon(
                              Icons.call_end_rounded,
                              color: Colors.red,
                            ),
                          const SizedBox(width: 10),
                          Text(
                            startTimeString,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(
                        height: 0.1,
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              );
  }
}
