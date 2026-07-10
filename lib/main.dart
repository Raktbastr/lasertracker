import 'package:flutter/material.dart';
import 'package:lasertracker/accountcreate.dart';
import 'package:lasertracker/core/api.dart';
import 'package:lasertracker/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'groupcreate.dart';
import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laser Tracker',
      theme: laserTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController groupCodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    groupCodeController.text = prefs.getString("loginGroupKey") ?? '';
    usernameController.text = prefs.getString("loginUsername") ?? '';
    pinController.text = prefs.getString("loginPin") ?? '';
  }

  @override
  void dispose() {
    groupCodeController.dispose();
    usernameController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Spacer(),
              Image.asset(
                "assets/tracker_logo-horizontal.png",
                height: 75,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: groupCodeController,
                decoration: const InputDecoration(
                  labelText: 'Group Code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          String groupCode = groupCodeController.text;
                          String username = usernameController.text;
                          String pin = pinController.text;
                          if (await groupLogin(groupCode, username, pin) ==
                              true) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text("Error: ${e.toString()}"),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }

                        setState(() {
                          isLoading = false;
                        });
                      },
                child: Text("Login"),
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text("Create an account"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AccountCreatePage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text("Create a group"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GroupCreatePage(),
                    ),
                  );
                },
              ),
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.settings),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
