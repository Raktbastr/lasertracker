import 'package:flutter/material.dart';
import 'package:lasertracker/widgets/logview.dart';
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
    MembersView(),
    LogView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[pageIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home, color: Color(0xff01ff92)), label: "Team"),
          NavigationDestination(icon: Icon(Icons.radar, color: Color(0xff01ff92)), label: "Members"),
          NavigationDestination(icon: Icon(Icons.access_time, color: Color(0xff01ff92)), label: "Log"),
          NavigationDestination(icon: Icon(Icons.settings, color: Color(0xff01ff92)), label: "Settings"),
        ],
        indicatorColor: Color.fromARGB(48, 116, 249, 156),
      ),
    );
  }
}
