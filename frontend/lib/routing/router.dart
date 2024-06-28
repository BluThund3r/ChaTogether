import 'package:flutter/material.dart';
import 'package:frontend/pages/add_friend_page.dart';
import 'package:frontend/pages/admin_stats.dart';
import 'package:frontend/pages/admin_users.dart';
import 'package:frontend/pages/auth_pages/login_page.dart';
import 'package:frontend/pages/auth_pages/mail_verification_page.dart';
import 'package:frontend/pages/auth_pages/register_page.dart';
import 'package:frontend/pages/blocked_users_page.dart';
import 'package:frontend/pages/call.dart';
import 'package:frontend/pages/chat_page.dart';
import 'package:frontend/pages/create_group_chat_page.dart';
import 'package:frontend/pages/create_private_chat_page.dart';
import 'package:frontend/pages/friends_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/navbar_pages/people_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/pages/test_page.dart';
import 'package:frontend/pages/video_room_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      redirect: (context, _) async {
        final isLoggedIn =
            await Provider.of<AuthService>(context, listen: false).isLoggedIn();
        if (!isLoggedIn) {
          return '/auth/login';
        }
        return null;
      },
    ),
    // GoRoute(    //   path: '/test',
    //   builder: (BuildContext context, GoRouterState state) {
    //     return TestPage();
    //   },
    // ),
    GoRoute(
        path: "/call/:chatRoomId",
        builder: (context, state) {
          final chatRoomId = state.pathParameters['chatRoomId'];
          if (chatRoomId == null) return const SizedBox();
          return CallPage(chatRoomId: chatRoomId);
        }),
    GoRoute(
      path: '/chat',
      builder: (BuildContext context, GoRouterState state) {
        return const TestPage();
      },
      routes: [
        GoRoute(
          path: 'createGroup',
          builder: (BuildContext context, GoRouterState state) {
            return const CreateGroupChatPage();
          },
        ),
        GoRoute(
          path: 'createPrivate',
          builder: (BuildContext context, GoRouterState state) {
            return const CreatePrivateChatPage();
          },
        ),
        //! This should be the last route in the list
        GoRoute(
          path: ':id',
          builder: (BuildContext context, GoRouterState state) {
            final id = state.pathParameters['id'];
            if (id == null) return const SizedBox();
            return ChatPage(chatId: id);
          },
        ),
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ],
    ),
    GoRoute(
      path: "/videoRoom",
      builder: (context, state) => const SizedBox(), // Add this line
      routes: [
        //! This should be the last route in the list
        GoRoute(
          path: ":connectionCode",
          builder: (context, state) {
            final connectionCode = state.pathParameters['connectionCode'];
            if (connectionCode == null) return const SizedBox();
            return VideoRoomPage(connectionCode: connectionCode);
          },
        ),
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ],
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfilePage();
      },
      redirect: (context, _) async {
        final isLoggedIn =
            await Provider.of<AuthService>(context, listen: false).isLoggedIn();
        if (!isLoggedIn) {
          return '/auth/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/people',
      builder: (BuildContext context, GoRouterState state) {
        return const PeoplePage();
      },
      routes: [
        GoRoute(
          path: 'friends',
          builder: (BuildContext context, GoRouterState state) {
            return const FriendsPage();
          },
        ),
        GoRoute(
          path: 'blocked',
          builder: (BuildContext context, GoRouterState state) {
            return const BlockedUsersPage();
          },
        ),
        GoRoute(
          path: 'addFriend',
          builder: (BuildContext context, GoRouterState state) {
            return const AddFriendPage();
          },
        ),
      ],
    ),
    GoRoute(
      path: "/admin",
      redirect: (context, state) async {
        final isAdmin =
            await Provider.of<AuthService>(context, listen: false).checkAdmin();
        if (!isAdmin) {
          return '/';
        }
        return null;
      },
      builder: (context, state) => const SizedBox(),
      routes: [
        GoRoute(
          path: 'statistics',
          builder: (BuildContext context, GoRouterState state) {
            return const AdminStats();
          },
        ),
        GoRoute(
          path: 'users',
          builder: (BuildContext context, GoRouterState state) {
            return const AdminUsers();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      redirect: (context, state) async {
        final isLoggedIn =
            await Provider.of<AuthService>(context, listen: false).isLoggedIn();
        if (isLoggedIn) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
        ),
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: 'verify-email',
          builder: (BuildContext context, GoRouterState state) {
            return const MailVerificationPage();
          },
        ),
      ],
    ),
  ],
);
