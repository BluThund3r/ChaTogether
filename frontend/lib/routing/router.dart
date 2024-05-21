import 'package:flutter/material.dart';
import 'package:frontend/pages/add_friend_page.dart';
import 'package:frontend/pages/auth_pages/login_page.dart';
import 'package:frontend/pages/auth_pages/mail_verification_page.dart';
import 'package:frontend/pages/auth_pages/register_page.dart';
import 'package:frontend/pages/blocked_users_page.dart';
import 'package:frontend/pages/friends_page.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/navbar_pages/people_page.dart';
import 'package:frontend/pages/profile_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return HomePage();
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
