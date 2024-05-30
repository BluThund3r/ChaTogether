import 'dart:convert';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:frontend/interfaces/user.dart';
import 'package:frontend/utils/crypto_utils.dart';
import 'package:frontend/utils/fetch_with_token.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<dynamic> getUsersNotRelated(String searchString) async {
    final response = await HttpWithToken.get(
      url: "$baseUrl/user/searchNotRelated?searchString=$searchString",
    );

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

  Future<dynamic> uploadUserRSAKeys(KeyPair keyPair, String password) async {
    final publicKey = keyPair.publicKey;
    final privateKey = keyPair.privateKey;
    final [derivedKey, salt] =
        await CryptoUtils.generateDerivedKeyAndSalt(password);
    final iv = CryptoUtils.generateIV();
    final encryptedPublicKeyBase64 =
        await CryptoUtils.encryptWithAES(privateKey, derivedKey, iv);
    final ivBase64 = iv.base64;
    final saltBase64 = base64Encode(salt);
    final concatenated = "$saltBase64.$ivBase64.$encryptedPublicKeyBase64";
    final response = await HttpWithToken.post(
      url: "$baseUrl/user/uploadKeys",
      body: {"publicKey": publicKey, "encryptedPrivateKey": concatenated},
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return null;
    } else {
      return response.body;
    }
  }

  Future<dynamic> fetchUserRSAKeys(String password) async {
    final response = await HttpWithToken.get(url: "$baseUrl/user/getKeys");
    if (response.statusCode != 200) {
      return response.body;
    }

    final body = jsonDecode(response.body);
    final concatenated = body["encryptedPrivateKey"];
    final publicKey = body["publicKey"];
    final [saltBase64, ivBase64, encryptedPrivateKeyBase64] =
        concatenated.split(".");
    final privateKey = await CryptoUtils.getPrivateKeyOfUser(
      encryptedPrivateKeyBase64,
      password,
      saltBase64,
      ivBase64,
    );

    return KeyPair(publicKey, privateKey);
  }
}
