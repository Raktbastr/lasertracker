// Alas, the best option for now was to have 2 pages.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});
  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String groupKey = "";

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    groupKey = prefs.getString("loginGroupKey") ?? "hi";
    setState(() {
      groupKey;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Column(
            children: [
              Text("Group Join Key", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(groupKey, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Log out'),
                        content: const Text('Are you sure you want to log out.'),
                        actions: <Widget>[
                          ElevatedButton(
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String url = prefs.getString("backendURL")!;
                              await prefs.clear();
                              prefs.setString("backendURL", url);
                              context.go('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            child: const Text('Yes'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('No'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Log out'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
