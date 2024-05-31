import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/interfaces/chat_room_details.dart';
import 'package:frontend/utils/backend_details.dart';

void showMembersModal(context, ChatRoomDetails chatRoomDetails) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Text(
                "Chat members",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  final member = chatRoomDetails.members[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: CustomCircleAvatar(
                        imageUrl:
                            '$baseUrl/user/profilePicture?username=${member.username}',
                        name: member.firstName,
                        radius: 25,
                      ),
                      title: Row(
                        children: [
                          Text(member.username),
                          const SizedBox(width: 10),
                          member.isAdminInChat
                              ? const Icon(
                                  Icons.star_rounded,
                                  color: Colors.grey,
                                )
                              : const SizedBox(),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.cancel_rounded,
                                color: Colors.red),
                            onPressed: () {},
                          ),
                          member.isAdminInChat
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {},
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.admin_panel_settings_rounded,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {},
                                ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: chatRoomDetails.members.length,
              ),
            )
          ],
        ),
      );
    },
  );
}
