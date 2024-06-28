import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/api/firebase_api.dart';
import 'package:frontend/routing/router.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/call_service.dart';
import 'package:frontend/services/chat_message_service.dart';
import 'package:frontend/services/chat_room_service.dart';
import 'package:frontend/services/friend_service.dart';
import 'package:frontend/services/stomp_service.dart';
import 'package:frontend/services/user_service.dart';
import 'package:frontend/services/video_room_service.dart';
import 'package:frontend/utils/backend_details.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  print("Domain: $baseUrl");
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  final stompService = StompService();
  final authService = AuthService();
  if (await authService.isLoggedIn()) {
    stompService.openWsConnection();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) {
      runApp(
        MultiProvider(
          providers: [
            Provider<AuthService>(
              create: (_) => AuthService(),
            ),
            Provider<FriendService>(
              create: (_) => FriendService(),
            ),
            Provider<UserService>(
              create: (_) => UserService(),
            ),
            Provider<ChatRoomService>(
              create: (_) => ChatRoomService(),
            ),
            Provider<ChatMessageService>(
              create: (_) => ChatMessageService(),
            ),
            Provider<VideoRoomService>(
              create: (_) => VideoRoomService(),
            ),
            Provider<AdminService>(
              create: (_) => AdminService(),
            ),
            Provider<CallService>(
              create: (_) => CallService(),
            ),
            // other services that need to be injected
          ],
          child: const MyApp(),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'ChaTogether',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Color.fromARGB(255, 0, 163, 238),
          onPrimary: Color(0xFFFFFFFF),
          secondary: Color.fromARGB(255, 0, 212, 219),
          onSecondary: Color.fromARGB(255, 50, 50, 50),
        ),
      ),
    );
  }
}
