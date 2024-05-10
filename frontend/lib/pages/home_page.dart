import 'package:flutter/material.dart';
import 'package:frontend/pages/navbar_pages/calls_page.dart';
import 'package:frontend/pages/navbar_pages/chats_page.dart';
import 'package:frontend/pages/navbar_pages/people_page.dart';
import 'package:frontend/pages/navbar_pages/watch_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  final navbarPages = <Widget>[
    const ChatsPage(),
    const PeoplePage(),
    const CallsPage(),
    const WatchPage(),
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthService authService;
  int currentPageIndex = 0;
  late List<FloatingActionButton?> actionButtons;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    actionButtons = <FloatingActionButton?>[
      FloatingActionButton(
        onPressed: () {
          // TODO: Add the routing for creating a new chat
        },
        child: const Icon(Icons.add_comment_rounded),
      ),
      FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push('/people/addFriend');
        },
        child: const Icon(Icons.person_add),
      ),
      null,
      null,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ChaTogether',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        actions: [
          FutureBuilder(
              future: authService.getLoggedInUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Text("${snapshot.data?.username}");
                } else {
                  return const SizedBox();
                }
              }),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authService.logout();
              GoRouter.of(context).go('/auth/login');
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (newIndex) => setState(
          () {
            currentPageIndex = newIndex;
          },
        ),
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.message_rounded),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'People',
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_rounded),
            label: 'Calls',
          ),
          NavigationDestination(
            icon: Icon(Icons.live_tv_rounded),
            label: 'Watch',
          ),
        ],
      ),
      body: widget.navbarPages[currentPageIndex],
      floatingActionButton: actionButtons[currentPageIndex],
    );
  }
}
