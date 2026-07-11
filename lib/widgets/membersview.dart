import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  List<String> locations = [
    "In cafeteria",
    "In stands",
    "In pits",
    "In Impact Award room",
    "In Leadership Award room",
    "In Woodie Flowers Award room",
    "In Queuing/Field",
    "At Home",
    "Custom",
  ];

  List<String> jobs = [
    "Safety Captain",
    "Drive Team - Drive Coach",
    "Drive Team - Driver",
    "Drive Team - Tech Driver",
    "Drive Team - Technician",
    "Impact Award presenter",
    "Student Ambassador",
    "Custom",
  ];

  List<String> roles = ["student", "Mentor", "Lead Coach 1", "Lead Coach 2"];

  String currLoc = "";
  String currJob = "";
  String currRole = "";

  final TextEditingController locationController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  List<DropdownMenuEntry> listToEntries(List list) {
    List<DropdownMenuEntry> entries = [];
    for (var item in list) {
      var entry = DropdownMenuEntry(value: item, label: item);
      entries.add(entry);
    }
    return entries;
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      currLoc = prefs.getString("job")!;
      currJob = prefs.getString("location")!;
      currRole = prefs.getString("role")!;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Column(
          children: [
            Text("You"),
            Row(
              children: [
                Expanded(
                  child: DropdownMenu(
                    controller: locationController,
                    expandedInsets: EdgeInsets.zero,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    onSelected: (value) {
                      try {
                        setJob(value.toString());
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
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownMenu(
                    controller: jobController,
                    expandedInsets: EdgeInsets.zero,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    onSelected: (value) {
                      try {
                        setJob(value.toString());
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
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownMenu(
                    expandedInsets: EdgeInsets.zero,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(),
                    ),
                    onSelected: (value) {
                      try {
                        setJob(value.toString());
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
                    enabled: false,
                    initialSelection: currRole,
                    dropdownMenuEntries: listToEntries([currRole]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
