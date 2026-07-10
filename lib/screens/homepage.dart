import 'package:flutter/material.dart';
import 'package:lasertracker/widgets/groupchatview.dart';
import 'package:lasertracker/widgets/membersview.dart';
import 'package:lasertracker/widgets/settingsview.dart';
import 'package:lasertracker/widgets/teamview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final List<Widget> pages = const [
    TeamView(),
    GroupChatView(),
    MembersView(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: pages[pageIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home), label: "Team"),
          NavigationDestination(icon: Icon(Icons.chat), label: "Group Chat"),
          NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: "Members"),
          NavigationDestination(icon: Icon(Icons.settings), label: "Settings")
        ],
        indicatorColor: Color(0xFFfcd804),
      ),
    );
  }
}
