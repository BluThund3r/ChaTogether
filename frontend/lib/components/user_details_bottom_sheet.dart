import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar_no_cache.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/user_details_for_admin.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';

class UserDetailsBottomSheet extends StatefulWidget {
  final UserDetailsForAdmin user;
  final bool isCurrentuser;
  final void Function(int) toggleUserRole;
  const UserDetailsBottomSheet(
      {super.key,
      required this.user,
      required this.isCurrentuser,
      required this.toggleUserRole});

  @override
  State<UserDetailsBottomSheet> createState() => _UserDetailsBottomSheetState();
}

class _UserDetailsBottomSheetState extends State<UserDetailsBottomSheet> {
  late AdminService adminService;

  @override
  void initState() {
    super.initState();
    adminService = Provider.of<AdminService>(context, listen: false);
  }

  void removeAdminFromUser(context) async {
    final response = await adminService.removeAdmin(widget.user.id);

    if (response == null) {
      widget.toggleUserRole(widget.user.id);
    } else {
      initFToast(context);
      showErrorToast("Failed to remove admin from user");
    }
    Navigator.pop(context);
  }

  void grandAdminToUser(context) async {
    final response = await adminService.makeAdmin(widget.user.id);

    if (response == null) {
      widget.toggleUserRole(widget.user.id);
    } else {
      initFToast(context);
      showErrorToast("Failed to grant admin to user");
    }
    Navigator.pop(context);
  }

  void resendMailConfirmationToUser(context) async {
    final response =
        await adminService.resendConfirmationEmailToUser(widget.user.id);
    initFToast(context);
    if (response == null) {
      showOKToast("Mail confirmation sent to user");
    } else {
      showErrorToast("Failed to resend mail confirmation to user");
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomCircleAvatarNoCache(
                name: widget.user.firstName,
                imageUrl:
                    '$baseUrl/user/profilePicture?username=${widget.user.username}',
                radius: 75,
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.user.firstName} ${widget.user.lastName}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.user.username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                widget.user.email,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                !widget.user.confirmedMail
                    ? "User has not confirmed mail"
                    : widget.user.isAppAdmin
                        ? "User is an app admin"
                        : "User is not an app admin",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (!widget.user.confirmedMail)
                ElevatedButton(
                  onPressed: () => resendMailConfirmationToUser(context),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        const Color.fromARGB(255, 56, 105, 165)),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  child: const Text(
                    "Resend Mail Confirmation",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (widget.user.confirmedMail)
                widget.user.isAppAdmin
                    ? widget.isCurrentuser
                        ? const SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : ElevatedButton(
                            onPressed: () => removeAdminFromUser(context),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromARGB(255, 165, 56, 56)),
                              textStyle: MaterialStateProperty.all(
                                const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            child: const Text(
                              "Remove Admin",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                    : ElevatedButton(
                        onPressed: () => grandAdminToUser(context),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              const Color.fromARGB(255, 49, 123, 51)),
                          textStyle: MaterialStateProperty.all(
                            const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        child: const Text(
                          "Grant Admin",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
            ],
          )),
    );
  }
}
