import 'package:flutter/material.dart';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});
  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController eventCodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController displaynameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Spacer(),
              SizedBox(height: 16),
              TextField(
                controller: groupNameController,
                decoration: InputDecoration(
                  labelText: 'Team/Group Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Dropdown for event code, offseason/custom event option
              SizedBox(height: 32),
              Text("The following info will be used to create the 'Coach Account' for your group. This account will be used to log in to the group and manage your group settings.", 
                style: TextStyle(fontSize: 14), textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextField(
                controller: displaynameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              Text("This is the name that will be displayed to other users in the group.", 
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              Text("This is the name that will be used to log in to the group.", 
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  border: OutlineInputBorder(),
                ),
              ),
              Text("This is the PIN that will be used to log in to the group.", 
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Create group logic here
                },
                child: isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text('Create Group'),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
