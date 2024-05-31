import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/interfaces/chat_message.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoUtils {
  static const int _SALT_LENGTH = 16;
  static const int _ITERATIONS = 1000;
  static const int _DERIVED_KEY_LENGTH = 32;
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();
  static const int _IV_SIZE = 16;
  static const int _RSA_KEY_SIZE = 2048;
  static const int _AES_KEY_SIZE = 32;

  static Future<void> storeUserRSAKeys(KeyPair keyPair) async {
    await _secureStorage.write(
      key: "userPublicKey",
      value: keyPair.publicKey,
    );
    await _secureStorage.write(
      key: "userPrivateKey",
      value: keyPair.privateKey,
    );
  }

  static Future<KeyPair?> getUserRSAKeys() async {
    final publicKey = await _secureStorage.read(key: "userPublicKey");
    final privateKey = await _secureStorage.read(key: "userPrivateKey");
    if (publicKey == null || privateKey == null) return null;

    return KeyPair(publicKey, privateKey);
  }

  static Future<void> storeConversationKeyAndIV(
    String conversationId,
    Uint8List key,
    encrypt.IV iv,
  ) async {
    await _secureStorage.write(
      key: "conversationKey.$conversationId",
      value: base64Encode(key),
    );
    await _secureStorage.write(
      key: "conversationIV.$conversationId",
      value: iv.base64,
    );
  }

  static Future<List<dynamic>?> getConversationKeyAndIV(
      String conversationId) async {
    final key =
        await _secureStorage.read(key: "conversationKey.$conversationId");
    final iv = await _secureStorage.read(key: "conversationIV.$conversationId");
    if (key == null || iv == null) return null;
    return [base64Decode(key), encrypt.IV.fromBase64(iv)];
  }

  static Future<List<dynamic>> decryptConversationKeyAndIv(
      String encryptedKeyAndIvBase64) async {
    final privateKey = (await getUserRSAKeys())!.privateKey;
    final decryptedKeyAndIv = await decryptWithRSA(
      encryptedKeyAndIvBase64,
      privateKey,
    );
    final [ivString, keyString] = decryptedKeyAndIv.split(".");
    final iv = encrypt.IV.fromBase64(ivString);
    final key = base64Decode(keyString);
    return [key, iv];
  }

  static Future<KeyPair> generateRSAKeyPair() async {
    final keyPair = await RSA.generate(_RSA_KEY_SIZE);
    final publicKeyConverted =
        await RSA.convertPublicKeyToPKIX(keyPair.publicKey);
    final privateKeyConverted =
        await RSA.convertPrivateKeyToPKCS8(keyPair.privateKey);
    return KeyPair(publicKeyConverted, privateKeyConverted);
  }

  static Future<String> encryptWithRSA(
      String plaintext, String publicKey) async {
    return await RSA.encryptOAEP(plaintext, "", Hash.SHA256, publicKey);
  }

  static Future<String> decryptWithRSA(
      String ciphertext, String privateKey) async {
    return await RSA.decryptOAEP(ciphertext, "", Hash.SHA256, privateKey);
  }

  static encrypt.IV generateIV() {
    return encrypt.IV.fromLength(_IV_SIZE);
  }

  static Uint8List generateRandomSalt(int length) {
    final secureRandom = Random.secure();
    return Uint8List.fromList(
        List<int>.generate(length, (_) => secureRandom.nextInt(256)));
  }

  static Future<Uint8List> getDerivedKey(
    String password,
    Uint8List salt,
  ) async {
    final pbkdf2 = PBKDF2KeyDerivator(HMac(Digest("SHA-256"), 64));
    final params = Pbkdf2Parameters(
      salt,
      _ITERATIONS,
      _DERIVED_KEY_LENGTH,
    );

    pbkdf2.init(params);
    return pbkdf2.process(Uint8List.fromList(password.codeUnits));
  }

  static Future<List<Uint8List>> generateDerivedKeyAndSalt(
      String password) async {
    final salt = generateRandomSalt(_SALT_LENGTH);
    final derivedKey = await getDerivedKey(password, salt);
    return [derivedKey, salt];
  }

  static Future<String> encryptWithAES(
    String plaintext,
    Uint8List key,
    encrypt.IV iv,
  ) async {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key(key),
        mode: encrypt.AESMode.cbc,
      ),
    );

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return encrypted.base64;
  }

  static Future<ChatMessage> decryptChatMessage(
      ChatMessage message, Uint8List chatRoomKey, encrypt.IV chatRoomIV) async {
    final decryptedMessage = await decryptWithAES(
      message.encryptedContent,
      chatRoomKey,
      chatRoomIV,
    );

    message.content = decryptedMessage;
    return message;
  }

  static Future<List<ChatMessage>> decryptChatMessages(
      List<ChatMessage> messages,
      Uint8List chatRoomKey,
      encrypt.IV chatRoomIV) async {
    final decryptedMessages = <ChatMessage>[];
    for (final message in messages) {
      final decryptedMessage =
          await decryptChatMessage(message, chatRoomKey, chatRoomIV);
      decryptedMessages.add(decryptedMessage);
    }

    return decryptedMessages;
  }

  static Future<String> decryptWithAES(
    String ciphertext,
    Uint8List key,
    encrypt.IV iv,
  ) async {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        encrypt.Key(key),
        mode: encrypt.AESMode.cbc,
      ),
    );

    final decrypted = encrypter.decrypt(
      encrypt.Encrypted.fromBase64(ciphertext),
      iv: iv,
    );
    return decrypted;
  }

  static Future<String> getPrivateKeyOfUser(
    String encryptedPrivateKeyBase64,
    String password,
    String saltBase64,
    String ivBase64,
  ) async {
    final salt = base64Decode(saltBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final derivedKey = await getDerivedKey(password, salt);
    final privateKey = await decryptWithAES(
      encryptedPrivateKeyBase64,
      derivedKey,
      iv,
    );
    return privateKey;
  }

  static Future<String> getPrivateKeyFromEncrypted(
      String concatenated, String password) async {
    final [saltBase64, ivBase64, encryptedPrivateKeyBase64] =
        concatenated.split(".");
    return await CryptoUtils.getPrivateKeyOfUser(
      encryptedPrivateKeyBase64,
      password,
      saltBase64,
      ivBase64,
    );
  }

  static Future<String> encryptPrivateKeyOfUser(
      String privateKey, String password) async {
    final [derivedKey, salt] = await generateDerivedKeyAndSalt(password);
    final iv = generateIV();
    final encryptedPublicKeyBase64 =
        await CryptoUtils.encryptWithAES(privateKey, derivedKey, iv);
    final ivBase64 = iv.base64;
    final saltBase64 = base64Encode(salt);
    final concatenated = "$saltBase64.$ivBase64.$encryptedPublicKeyBase64";
    return concatenated;
  }
}
