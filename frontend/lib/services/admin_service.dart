import 'dart:convert';

import 'package:frontend/interfaces/stats.dart';
import 'package:frontend/interfaces/user_details_for_admin.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:frontend/utils/fetch_with_token.dart';

class AdminService {
  Future<dynamic> getStats() async {
    final response = await HttpWithToken.get(url: "$baseUrl/admin/getStats");

    if (response.statusCode != 200) return response.body;
    List<Stats> stats = jsonDecode(response.body)
        .map((stat) => Stats.fromJson(stat))
        .cast<Stats>()
        .toList();

    return stats;
  }

  Future<dynamic> getUsers() async {
    final response = await HttpWithToken.get(url: "$baseUrl/admin/getAllUsers");

    if (response.statusCode != 200) return response.body;
    List<UserDetailsForAdmin> users = jsonDecode(response.body)
        .map((user) => UserDetailsForAdmin.fromJson(user))
        .cast<UserDetailsForAdmin>()
        .toList();

    return users;
  }

  Future<String?> makeAdmin(int userId) async {
    final response =
        await HttpWithToken.post(url: "$baseUrl/admin/makeAdmin/$userId");

    if (response.statusCode != 200) return response.body;
    return null;
  }

  Future<String?> removeAdmin(int userId) async {
    final response =
        await HttpWithToken.post(url: "$baseUrl/admin/removeAdmin/$userId");

    if (response.statusCode != 200) return response.body;
    return null;
  }

  Future<String?> resendConfirmationEmailToUser(int userId) async {
    final response = await HttpWithToken.post(
        url: "$baseUrl/admin/resendConfirmationEmailToUser/$userId");

    if (response.statusCode != 200) return response.body;
    return null;
  }
}
