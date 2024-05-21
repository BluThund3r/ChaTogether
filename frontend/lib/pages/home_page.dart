import 'package:flutter/material.dart';
import 'package:frontend/components/custom_circle_avatar.dart';
import 'package:frontend/pages/navbar_pages/calls_page.dart';
import 'package:frontend/pages/navbar_pages/chats_page.dart';
import 'package:frontend/pages/navbar_pages/people_page.dart';
import 'package:frontend/pages/navbar_pages/watch_page.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/backend_details.dart';
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FutureBuilder(
              future: authService.getLoggedInUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return IconButton(
                    onPressed: () => GoRouter.of(context).push('/profile'),
                    icon: CustomCircleAvatar(
                      radius: 18.0,
                      imageUrl:
                          "$baseUrl/user/profilePicture?username=${(snapshot.data as LoggedUserInfo).username}",
                      name: (snapshot.data as LoggedUserInfo).firstName,
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
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
