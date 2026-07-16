import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopMembersView extends StatefulWidget {
  const DesktopMembersView({super.key});

  @override
  State<DesktopMembersView> createState() => _DesktopMembersViewState();
}

class _DesktopMembersViewState extends State<DesktopMembersView> {
  List<String> locations = [
    "Cafeteria",
    "Stands",
    "Pits",
    "Impact Award room",
    "Leadership Award room",
    "Woodie Flowers Award room",
    "Queuing/Field",
    "At Home",
    "Quiet Room",
    "Custom",
  ];

  List<String> jobs = [
    "Safety Captain",
    "Drive Team - Drive Coach",
    "Drive Team - Driver",
    "Drive Team - Tech Driver",
    "Drive Team - Technician",
    "Impact Award Presenter",
    "Student Ambassador",
    "Custom",
  ];

  List<String> roles = ["Student", "Mentor", "Lead Coach 1", "Lead Coach 2"];

  String currLoc = "";
  String currJob = "";
  String currRole = "";
  String loggedInUsername = "";
  bool userIsAdmin = false;
  Future<List<dynamic>>? membersFuture;
  Future<bool>? isAdminFuture;

  Timer? refreshTimer;

  final TextEditingController locationController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController customJobController = TextEditingController();
  final TextEditingController customLocationController = TextEditingController();
  final TextEditingController newPinController = TextEditingController();

  List<DropdownMenuEntry> listToEntries(List list) {
    List<DropdownMenuEntry> entries = [];
    for (var item in list) {
      var entry = DropdownMenuEntry(value: item, label: item);
      entries.add(entry);
    }
    return entries;
  }

  void loadData() async {
    membersFuture = getMembers();
    isAdminFuture = isAdmin();
    final prefs = await SharedPreferences.getInstance();
    userIsAdmin = await isAdmin();

    setState(() {
      currLoc = prefs.getString("location") ?? "";
      currJob = prefs.getString("job") ?? "";
      currRole = prefs.getString("role") ?? "";
      loggedInUsername = prefs.getString("loginUsername") ?? "";
      locationController.text = currLoc;
      jobController.text = currJob;
      userIsAdmin = userIsAdmin;
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    jobController.dispose();
    roleController.dispose();
    customJobController.dispose();
    customLocationController.dispose();
    newPinController.dispose();
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadData();

    refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        silentRefresh();
      }
    });
  }

  Future<void> silentRefresh() async {
    setState(() {
      membersFuture = getMembers();
      isAdminFuture = isAdmin();
    });
  }

  Future<bool?> showEditDialog(
    BuildContext context,
    String role,
    ScaffoldMessengerState scaffoldMessenger,
    var memberData,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController memberRoleController = TextEditingController(text: role);
        bool isAdmin;
        if (memberData["is_admin"] == 1) {
          isAdmin = true;
        } else {
          isAdmin = false;
        }
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("Edit Member"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownMenu(
                      expandedInsets: EdgeInsets.zero,
                      controller: memberRoleController,
                      label: Text("Role", style: Theme.of(context).textTheme.titleSmall),
                      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
                      initialSelection: role,
                      enabled: userIsAdmin && (memberData["username"] != loggedInUsername),
                      dropdownMenuEntries: listToEntries(roles),
                      onSelected: (value) {
                        memberRoleController.text = value ?? "";
                      },
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text("User is admin"),
                      value: isAdmin,
                      onChanged: (bool? newValue) {
                        if (newValue == null) return;
                        setState(() {
                          isAdmin = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPinController,
                      decoration: const InputDecoration(labelText: "New Pin (Optional)", border: OutlineInputBorder()),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (newPinController.text != "") {
                        await changePin(memberData["username"], newPinController.text);
                        newPinController.text = "";
                      }
                      await changeRole(memberData["username"], memberRoleController.text);
                      await changeAdmin(memberData["username"], isAdmin);
                      scaffoldMessenger.showSnackBar(const SnackBar(content: Text("Member updated successfully!")));
                      if (context.mounted) {
                        Navigator.pop(context, true);
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
                  },
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: () {
                    newPinController.text = "";
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        silentRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Text("Your Status", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: DropdownMenu(
                      controller: locationController,
                      expandedInsets: EdgeInsets.zero,
                      label: const Text("Location"),
                      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
                      onSelected: (value) async {
                        try {
                          if (value == "Custom") {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Custom Location"),
                                  content: TextField(
                                    controller: customLocationController,
                                    decoration: const InputDecoration(
                                      labelText: "Location",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setString("location", customLocationController.text);
                                          await setStatus();
                                          locationController.text = customLocationController.text;
                                          Navigator.pop(context);
                                        } catch (e) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text("Error: ${e.toString()}"),
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Set Location'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        locationController.text = currLoc;
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString("location", value.toString());
                            await setStatus();
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
                      },
                      initialSelection: currLoc,
                      dropdownMenuEntries: listToEntries(locations),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownMenu(
                      controller: jobController,
                      expandedInsets: EdgeInsets.zero,
                      label: const Text("Job"),
                      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
                      onSelected: (value) async {
                        try {
                          if (value == "Custom") {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Custom Job"),
                                  content: TextField(
                                    controller: customJobController,
                                    decoration: const InputDecoration(
                                      labelText: "Job Title",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setString("job", customJobController.text);
                                          await setStatus();
                                          jobController.text = customJobController.text;
                                          Navigator.pop(context);
                                        } catch (e) {
                                          scaffoldMessenger.showSnackBar(
                                            SnackBar(
                                              content: Text("Error: ${e.toString()}"),
                                              behavior: SnackBarBehavior.floating,
                                              margin: const EdgeInsets.all(16),
                                            ),
                                          );
                                        }
                                      },
                                      child: const Text('Set Job'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        jobController.text = currJob;
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString("job", value.toString());
                            await setStatus();
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
                      },
                      initialSelection: currJob,
                      dropdownMenuEntries: listToEntries(jobs),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownMenu(
                      expandedInsets: EdgeInsets.zero,
                      controller: roleController,
                      label: const Text("Role"),
                      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
                      enabled: false,
                      initialSelection: currRole,
                      onSelected: (value) async {
                        try {
                          await changeRole(loggedInUsername, value ?? "");
                        } on Exception catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text("Error: ${e.toString()}"),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      },
                      dropdownMenuEntries: listToEntries(roles),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text("Team Members", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 16),

              FutureBuilder(
                future: Future.wait<dynamic>([?membersFuture, ?isAdminFuture]),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error fetching members"));
                  }
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    final results = snapshot.data as List<dynamic>;
                    final List members = results[0] as List;
                    final bool admin = results[1] as bool;

                    final Map<String, List> groups = {};
                    for (var m in members) {
                      final loc = (m["location"] ?? "Unknown") as String;
                      if (m["username"] == loggedInUsername) {
                        if (members.length - 1 == 0) {
                          return const Center(
                            child: Padding(padding: EdgeInsets.all(16), child: Text("No Members")),
                          );
                        }
                        continue;
                      } else {
                        groups.putIfAbsent(loc, () => []).add(m);
                      }
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groups.entries.map((entry) {
                        final loc = entry.key;
                        final list = entry.value;
                        final bool canEditUser = admin;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 16, bottom: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  loc,
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Name",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Role",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Job",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ),
                                      canEditUser
                                          ? const SizedBox(width: 48)
                                          : const SizedBox(width: 0),
                                    ],
                                  ),
                                ),
                                ...list.map<Widget>((member) {
                                  final name = member["display_name"] ?? "";
                                  final role = member["role"] ?? "";
                                  final job = member["job"] ?? "";

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Column(
                                      children: [
                                        const Divider(),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.titleSmall,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                role,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.titleSmall,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                job,
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context).textTheme.titleSmall,
                                              ),
                                            ),
                                            canEditUser
                                                ? IconButton.filled(
                                                    onPressed: () async {
                                                      final bool? updated = await showEditDialog(
                                                        context,
                                                        role,
                                                        scaffoldMessenger,
                                                        member,
                                                      );
                                                      if (updated == true) {
                                                        setState(() {});
                                                      }
                                                    },
                                                    icon: const Icon(Icons.edit),
                                                  )
                                                : const SizedBox(width: 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
