import 'package:flutter/material.dart';
import 'package:lasertracker/widgets/desktop/logview.dart';
import 'package:lasertracker/widgets/desktop/membersview.dart';
import 'package:lasertracker/widgets/desktop/teamview.dart';
import 'package:lasertracker/widgets/mobile/logview.dart';
import 'package:lasertracker/widgets/mobile/membersview.dart';
import 'package:lasertracker/widgets/mobile/settingsview.dart';
import 'package:lasertracker/widgets/mobile/teamview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pageIndex = 0;

  final List<Widget> desktopPages = const [DesktopTeamView(), DesktopMembersView(), DesktopLogView(), SettingsView()];

  final List<Widget> mobilePages = const [MobileTeamView(), MobileMembersView(), MobileLogView(), SettingsView()];

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      body: SafeArea(
        child: isWideScreen
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: pageIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        pageIndex = index;
                      });
                    },
                    leading: Image.asset("assets/tracker_icon.png", width: 64),
                    labelType: NavigationRailLabelType.all,
                    indicatorColor: const Color.fromARGB(48, 116, 249, 156),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        selectedIcon: Icon(Icons.home, color: Color(0xff01ff92)),
                        label: Text('Team'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.radar),
                        selectedIcon: Icon(Icons.radar, color: Color(0xff01ff92)),
                        label: Text('Members'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.access_time),
                        selectedIcon: Icon(Icons.access_time, color: Color(0xff01ff92)),
                        label: Text('Log'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        selectedIcon: Icon(Icons.settings, color: Color(0xff01ff92)),
                        label: Text('Settings'),
                      ),
                    ],
                  ),
                  Expanded(child: desktopPages[pageIndex]),
                ],
              )
            : mobilePages[pageIndex],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: pageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  pageIndex = index;
                });
              },
              indicatorColor: const Color.fromARGB(48, 116, 249, 156),
              destinations: const <Widget>[
                NavigationDestination(
                  icon: Icon(Icons.home, color: Color(0xff01ff92)),
                  label: 'Team',
                ),
                NavigationDestination(
                  icon: Icon(Icons.radar, color: Color(0xff01ff92)),
                  label: 'Members',
                ),
                NavigationDestination(
                  icon: Icon(Icons.access_time, color: Color(0xff01ff92)),
                  label: 'Log',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings, color: Color(0xff01ff92)),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}
