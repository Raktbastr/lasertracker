import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';
import 'package:lasertracker/homepage.dart';

class AccountCreatePage extends StatefulWidget {
  const AccountCreatePage({super.key});
  @override
  State<AccountCreatePage> createState() => _AccountCreatePageState();
}

class _AccountCreatePageState extends State<AccountCreatePage> {
  final TextEditingController groupKeyController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    groupKeyController.dispose();
    usernameController.dispose();
    displayNameController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              SizedBox(height: 16),
              TextField(
                controller: groupKeyController,
                decoration: InputDecoration(
                  labelText: "Group Key",
                  border: OutlineInputBorder(),
                ),
              ),
              Text(
                "This is the group key given to you by your mentor/coach/",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: displayNameController,
                decoration: InputDecoration(
                  labelText: "Display Name",
                  border: OutlineInputBorder(),
                ),
              ),
              Text(
                "This is the name that will be displyed to other members in the group",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              Text(
                "This is the name you will use to log in to the group",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: "Pin/Password",
                  border: OutlineInputBorder(),
                ),
              ),
              Text(
                "This is the password you will use to log in to the group",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    if (await memberAdd(
                          usernameController.text,
                          displayNameController.text,
                          pinController.text,
                          groupKeyController.text,
                        ) ==
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
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
