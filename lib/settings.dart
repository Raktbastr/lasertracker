import 'package:flutter/material.dart';
import 'package:lasertracker/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController backendURLController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
    backendURLController.addListener(() {
      saveData();
    });
  }

  @override
  void dispose() {
    backendURLController.removeListener(() {});
    backendURLController.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (backendURLController.text == "") {
      await prefs.setString('backendURL', "https://api.lasertracker.laserrobotics.org");
    } else {
      await prefs.setString('backendURL', backendURLController.text);
    }
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('backendURL') ?? '';
    setState(() {
      backendURLController.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Laser Tracker Server URL",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                "Set the URL of the Laser Tracker Server instance. Leave it blank to use the default.",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backendURLController,
                decoration: InputDecoration(
                  labelText: "https://api.lasertracker.laserrobotics.org",
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Reset All Data'),
                    content: const Text('Are you sure you want to reset all data?'),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(),
                            ),
                          );
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
                    ]
                  );
                }
              );
            },
            child: const Text('Reset All Data'),
          ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
