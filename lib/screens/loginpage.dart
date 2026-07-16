import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../core/api.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController groupKeyController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    groupKeyController.text = prefs.getString("loginGroupKey") ?? '';
    usernameController.text = prefs.getString("loginUsername") ?? '';
    pinController.text = prefs.getString("loginPin") ?? '';
  }

  @override
  void dispose() {
    groupKeyController.dispose();
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
              Image.asset("assets/tracker_logo-horizontal.png", height: 75, alignment: Alignment.center),
              const SizedBox(height: 16),
              TextField(
                controller: groupKeyController,
                decoration: const InputDecoration(labelText: 'Group Code', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder()),
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
                          String groupKey = groupKeyController.text;
                          String username = usernameController.text;
                          String pin = pinController.text;
                          if (await groupLogin(groupKey, username, pin) == true) {
                            context.go('/home');
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
              TextButton(child: const Text("Create an account"), onPressed: () => context.push('/account-create')),
              const SizedBox(height: 16),
              TextButton(child: const Text("Create a group"), onPressed: () => context.push('/group-create')),
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  FloatingActionButton(onPressed: () => context.push('/url-change'), child: const Icon(Icons.link)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
