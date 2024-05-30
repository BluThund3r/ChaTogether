import 'dart:convert';

import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompService {
  static final StompService _instance = StompService._privateConstructor();
  late StompClient _stompClient;
  late final AuthService authService;
  final _sendBaseUrl = '/app';
  final _receiveBaseUrl = '/user';

  StompService._privateConstructor() {
    authService = AuthService();
    authService.getAuthToken().then((token) {
      if (token == null) return;
      updateTokenInClient(token);
    });
  }

  factory StompService() {
    return _instance;
  }

  void updateTokenInClient(String token) {
    final connectionHeaders = {"Authorization": "Bearer $token"};
    _stompClient = StompClient(
      config: StompConfig(
        url: '$baseWsUrl/app',
        onConnect: (frame) {
          print("Connected to the websocket");
          _stompClient.subscribe(
            destination: '/user/inexistentDestination',
            callback: (frame) {
              print('Why would i receive anything?');
            },
          );
        },
        onWebSocketError: (error) {
          print('Error connecting to the websocket');
          print(error.toString());
        },
        stompConnectHeaders: connectionHeaders,
        webSocketConnectHeaders: connectionHeaders,
      ),
    );
  }

  void closeWsConnection() {
    _stompClient.deactivate();
  }

  void openWsConnection() {
    _stompClient.activate();
  }

  Function({Map<String, String>? unsubscribeHeaders}) subscribeToChatRoom(
      int chatRoomId, Function(StompFrame) callback) {
    return _stompClient.subscribe(
      destination: '$_receiveBaseUrl/chatRoom/$chatRoomId',
      callback: callback,
    );
  }

  Function({Map<String, String>? unsubscribeHeaders})
      subscribeToChatRoomUpdates(Function(StompFrame) callback) {
    return _stompClient.subscribe(
      destination: '$_receiveBaseUrl/chatRoomUpdates',
      callback: callback,
    );
  }

  Function({Map<String, String>? unsubscribeHeaders})
      subscribeToChatRoomAddOrRemove(Function(StompFrame) callback) {
    return _stompClient.subscribe(
      destination: "$_receiveBaseUrl/chatRoom/addOrRemove",
      callback: callback,
    );
  }

  void sendChatMessage(OutgoingChatMessage chatMessage, int chatRoomId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/sendMessage/$chatRoomId',
      body: json.encode(chatMessage.toJson()),
    );
  }

  void editChatMessage(int messageId, String newContent) {
    _stompClient.send(
      destination: '$_sendBaseUrl/editMessage/$messageId',
      body: newContent,
    );
  }

  void deleteChatMessage(int messageId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/deleteMessage/$messageId',
    );
  }

  void seeChatMessage(int messageId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/seeMessage/$messageId',
    );
  }

  void seeAllUnseenChatMessages(int chatRoomId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/seeAllMessages/$chatRoomId',
    );
  }
}
