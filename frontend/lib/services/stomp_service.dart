import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend/interfaces/outgoing_chat_message.dart';
import 'package:frontend/interfaces/video_change.dart';
import 'package:frontend/interfaces/video_position_change.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompService {
  static final StompService _instance = StompService._privateConstructor();
  late StompClient _stompClient;
  late final AuthService authService;
  final _sendBaseUrl = '/app';
  final _receiveBaseUrl = '/queue';

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
    print("Closing ws connection");
    _stompClient.deactivate();
  }

  void openWsConnection() {
    print("Opening ws connection");
    _stompClient.activate();
  }

  Function({Map<String, String>? unsubscribeHeaders}) subscribeToChatRoom(
      String chatRoomId, Function(StompFrame) callback) {
    return _stompClient.subscribe(
      destination: '$_receiveBaseUrl/chatRoom/$chatRoomId',
      callback: callback,
    );
  }

  Function({Map<String, String>? unsubscribeHeaders})
      subscribeToVideoRoomSignals(
          String connectionCode, Function(StompFrame) callback) {
    print("Subscribing to video room signals " + connectionCode);
    return _stompClient.subscribe(
      destination: '$_receiveBaseUrl/videoRoom/signal/$connectionCode',
      callback: callback,
    );
  }

  Function({Map<String, String>? unsubscribeHeaders})
      subscribeToVideoRoomJoinOrLeave(
    String connectionCode,
    Function(StompFrame) callback,
  ) {
    print("Subscribing to video room join or leave " + connectionCode);
    return _stompClient.subscribe(
      destination: '$_receiveBaseUrl/videoRoom/joinOrLeave/$connectionCode',
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

  void sendChatMessage(OutgoingChatMessage chatMessage, String chatRoomId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/sendMessage/$chatRoomId',
      body: json.encode(chatMessage.toJson()),
    );
  }

  void sendChatImage(Uint8List encryptedImageBytes, String chatRoomId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/sendChatImage/$chatRoomId',
      binaryBody: encryptedImageBytes,
    );
  }

  void editChatMessage(String messageId, String newContent) {
    _stompClient.send(
      destination: '$_sendBaseUrl/editMessage/$messageId',
      body: newContent,
    );
  }

  void deleteChatMessage(String messageId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/deleteMessage/$messageId',
    );
  }

  void restoreChatMessage(String messageId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/restoreMessage/$messageId',
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

  void seeMessage(String id, String chatId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/seeMessage/$id',
    );
  }

  void seeAllMessages(String chatId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/seeAllMessages/$chatId',
    );
  }

  void sendLeaveSignal(String connectionCode) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/leave/$connectionCode',
    );
  }

  void sendPauseSignal(String connectionCode) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/pause/$connectionCode',
    );
  }

  void sendResumeSignal(String connectionCode) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/resume/$connectionCode',
    );
  }

  void sendSeekSignal(String connectionCode, String position, bool isPlaying) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/seekToPosition/$connectionCode',
      body: json.encode(
        VideoPositionChange(position: position, isPlaying: isPlaying).toJson(),
      ),
    );
  }

  void sendChangeVideoSignal(String connectionCode, String videoId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/changeVideo/$connectionCode',
      body: json.encode(VideoChange(newVideoId: videoId).toJson()),
    );
  }

  void sendSyncVideoRequest(String connectionCode) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/syncVideo/$connectionCode',
    );
  }

  void sendSyncVideoResponse(String connectionCode, String videoId) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/syncVideoResponse/$connectionCode',
      body: json.encode(VideoChange(newVideoId: videoId).toJson()),
    );
  }

  void sendSyncPositionRequest(String connectionCode) {
    _stompClient.send(
      destination: '$_sendBaseUrl/videoRoom/syncPosition/$connectionCode',
    );
  }

  void sendSyncPositionResponse(
      String connectionCode, String position, bool isPlaying) {
    _stompClient.send(
      destination:
          '$_sendBaseUrl/videoRoom/syncPositionResponse/$connectionCode',
      body: json.encode(
        VideoPositionChange(
          position: position,
          isPlaying: isPlaying,
        ).toJson(),
      ),
    );
  }
}
