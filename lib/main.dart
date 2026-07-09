import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'groupcreate.dart';

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

  Future<void> saveData() async {
    final storage = FlutterSecureStorage();
    await storage.write(key: "loginGroupCode", value: groupCodeController.text);
    await storage.write(key: "loginUsername", value: usernameController.text);
    await storage.write(key: "loginPin", value: pinController.text);
  }

  Future<void> loadData() async {
    final storage = FlutterSecureStorage();
    groupCodeController.text = await storage.read(key: "loginGroupCode") ?? '';
    usernameController.text = await storage.read(key: "loginUsername") ?? '';
    pinController.text = await storage.read(key: "loginPin") ?? '';
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
                "assets/logo.png",
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
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);

                        setState(() {
                          isLoading = true;
                        });

                        try {
                          await saveData();
                          String groupCode = groupCodeController.text;
                          String username = usernameController.text;
                          String pin = pinController.text;
                          // LOGIN LOGIC HERE
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
                child: const Text("or create a group"),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const GroupCreatePage(),
                    ),
                  );
                },
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
