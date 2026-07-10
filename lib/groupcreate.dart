import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';
import 'homepage.dart';
import 'dart:async';

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({super.key});
  @override
  State<GroupCreatePage> createState() => _GroupCreatePageState();
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  final TextEditingController teamNumController = TextEditingController();
  final TextEditingController eventCodeController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController displaynameController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController eventSelectorController = TextEditingController();

  String teamNum = "";
  String teamName = "";
  String eventCode = "";
  bool isLoading = false;
  Timer? debounce;

  @override
  void initState() {
    teamNumController.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    debounce?.cancel();
    teamNumController.removeListener(update);
    teamNumController.dispose();
    eventCodeController.dispose();
    usernameController.dispose();
    displaynameController.dispose();
    pinController.dispose();
    eventSelectorController.dispose();
    super.dispose();
  }

  void update() {
    if (debounce?.isActive ?? false) debounce!.cancel();
    
    debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        teamNum = teamNumController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              SizedBox(height: 16),
              TextField(
                controller: teamNumController,
                decoration: InputDecoration(
                  labelText: "Team Number",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Spacer(),
                    FutureBuilder<Image>(
                      future: getTeamAvatar(teamNum),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return snapshot.data!;
                        }
                        return SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    SizedBox(width: 8),
                    FutureBuilder<String>(
                      future: getTeamName(teamNum),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          teamName = snapshot.data!;
                          return Text(snapshot.data!);
                        }
                        return SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: getEvents(teamNum),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SizedBox(
                      height: 48,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Text("Failed to load events");
                  }
                  final entries =
                      snapshot.data?.map<DropdownMenuEntry<Object?>>((item) {
                        if (item is Map && item.length == 1) {
                          final displayName = item.keys.first.toString();
                          final value = item.values.first;
                          return DropdownMenuEntry<Object?>(
                            value: value,
                            label: displayName,
                          );
                        }
                        return DropdownMenuEntry<Object?>(
                          value: item,
                          label: item.toString(),
                        );
                      }).toList() ??
                      [];
                  return DropdownMenu<Object?>(
                    controller: eventSelectorController,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    label: Text("Select Event"),
                    onSelected: (value) {
                      eventCode = value.toString();
                    },
                    dropdownMenuEntries: entries,
                  );
                },
              ),
              SizedBox(height: 32),
              Text(
                "The following info will be used to create the 'Coach Account' for your group. This account will be used to log in to the group and manage your group settings.",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextField(
                controller: displaynameController,
                decoration: InputDecoration(
                  labelText: "Display Name",
                  border: OutlineInputBorder(),
                ),
              ),
              Text(
                "This is the name that will be displayed to other members in the group.",
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
                "This is the name that will be used to log in to the group.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              TextField(
                controller: pinController,
                decoration: InputDecoration(
                  labelText: "PIN",
                  border: OutlineInputBorder(),
                ),
              ),
              Text(
                "This is the password that will be used to log in to the group.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  setState(() {
                    isLoading = true;
                  });

                  try {
                    if (await groupCreate(
                          teamName,
                          eventCode,
                          int.parse(teamNum),
                          usernameController.text,
                          displaynameController.text,
                          pinController.text,
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
                    : Text("Create Group"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
