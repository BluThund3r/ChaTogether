import 'dart:convert';

import 'package:frontend/interfaces/user.dart';
import 'package:frontend/utils/fetch_with_token.dart';
import 'package:frontend/utils/backend_details.dart';

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
}
