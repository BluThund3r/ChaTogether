import 'dart:convert';

import 'package:frontend/interfaces/user.dart';
import 'package:frontend/utils/fetch_with_token.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<dynamic> getUsersNotRelated(String searchString) async {
    final response = await HttpWithToken.get(
        url: "$baseUrl/user/searchNotRelated?searchString=$searchString");

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      return response.body;
    }
  }

  Future<dynamic> updateProfilePicture(String imagePath) async {
    final streamedResponse = await HttpWithToken.postFile(
      filePath: imagePath,
      url: "$baseUrl/user/uploadProfilePicture",
    );

    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }
}
