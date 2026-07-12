import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamView extends StatefulWidget {
  const TeamView({super.key});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView> {
  String teamNum = "";
  String groupName = "";
  String eventKey = "";
  String joinKey = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      teamNum = prefs.getString("team_number") ?? "";
      groupName = prefs.getString("group_name") ?? "";
      eventKey = prefs.getString("event_key") ?? "";
      joinKey = prefs.getString("join_key") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (teamNum.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              height: 40,
              child: FutureBuilder<Image>(
                future: getTeamAvatar(teamNum),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(groupName, style: Theme.of(context).textTheme.titleLarge),
                Text("Team $teamNum"),
              ],
            ),
            Spacer(),
            Column(
              children: [
                Text("Join Key", style: Theme.of(context).textTheme.titleLarge),
                Text(joinKey)
              ],
            )
          ],
        ),
        const SizedBox(height: 24),
        FutureBuilder(
          future: getMatches(teamNum, eventKey),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return const Text("Failed to retrieve match info.");
            }

            final data = snapshot.data as List<dynamic>;
            List<List<dynamic>> matches = [];

            for (var match in data) {
              if (match["actual_time"] == null) {
                String matchKey = match["key"].toString().replaceAll(
                  "${eventKey}_",
                  "",
                );
                String matchNum = "Unknown";

                if (matchKey.startsWith("qm")) {
                  matchNum = "Quals ${matchKey.replaceFirst("qm", "")}";
                } else if (matchKey.startsWith("sf")) {
                  final sfMatch = RegExp(
                    r'^sf(\d+)m(\d+)$',
                  ).firstMatch(matchKey);

                  if (sfMatch != null) {
                    int bracketMatchNumber = int.parse(sfMatch.group(1)!);
                    String roundName;

                    switch (bracketMatchNumber) {
                      case 1:
                      case 2:
                      case 3:
                      case 4:
                        roundName = "Upper Round 1";
                        break;
                      case 5:
                      case 6:
                        roundName = "Lower Round 1";
                        break;
                      case 7:
                      case 8:
                        roundName = "Upper Round 2";
                        break;
                      case 9:
                      case 10:
                        roundName = "Lower Round 2";
                        break;
                      case 11:
                        roundName = "Lower Round 3";
                        break;
                      case 12:
                        roundName = "Upper Round 3";
                        break;
                      case 13:
                        roundName = "Lower Finals";
                        break;
                      default:
                        roundName = "Playoffs";
                    }

                    matchNum = "$roundName\n(Match $bracketMatchNumber)";
                  } else {
                    matchNum = "Playoffs ${matchKey.replaceFirst("sf", "")}";
                  }
                } else if (matchKey.startsWith("f")) {
                  final fMatch = RegExp(r'^f\d+m(\d+)$').firstMatch(matchKey);

                  if (fMatch != null) {
                    matchNum = "Finals Match ${fMatch.group(1)}";
                  } else {
                    matchNum = "Finals ${matchKey.replaceFirst("f", "")}";
                  }
                }

                List<String> redTeams =
                    (match["alliances"]["red"]["team_keys"] as List)
                        .map((team) => team.toString().replaceAll("frc", ""))
                        .toList();

                List<String> blueTeams =
                    (match["alliances"]["blue"]["team_keys"] as List)
                        .map((team) => team.toString().replaceAll("frc", ""))
                        .toList();

                int? timestamp = match["predicted_time"] ?? match["time"];
                String timeStr = "TBD";

                if (timestamp != null) {
                  DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                    timestamp * 1000,
                  );
                  timeStr =
                      "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                }

                matches.add([matchNum, timeStr, redTeams, blueTeams]);
              }
            }

            if (matches.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No Upcoming Matches"),
                ),
              );
            }

            var nextMatch = matches[0];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Next Match",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(
                      builder: (context) {
                        if (nextMatch[2][0] == teamNum ||
                            nextMatch[2][1] == teamNum ||
                            nextMatch[2][2] == teamNum) {
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Red Alliance",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${nextMatch[2][0]}, ${nextMatch[2][1]}, ${nextMatch[2][2]}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Red Alliance",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.red),
                                ),
                                Text(
                                  "${nextMatch[2][0]} ${nextMatch[2][1]} ${nextMatch[2][2]}",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            "${nextMatch[0]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Text("VS"),
                          Text("${nextMatch[1]}"),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        if (nextMatch[3][0] == teamNum ||
                            nextMatch[3][1] == teamNum ||
                            nextMatch[3][2] == teamNum) {
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Blue Alliance",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${nextMatch[3][0]} ${nextMatch[3][1]} ${nextMatch[3][2]}",
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Blue Alliance",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text(
                                  "${nextMatch[3][0]} ${nextMatch[3][1]} ${nextMatch[3][2]}",
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),

                if (matches.length > 1) ...[
                  Padding(
                    padding: EdgeInsets.only(top: 24.0, bottom: 8.0),
                    child: Text(
                      "Upcoming Matches",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: matches.length - 1,
                    itemBuilder: (context, index) {
                      var upcomingMatch = matches[index + 1];
                      return Column(
                        children: [
                          const SizedBox(height: 5),
                          Divider(),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Builder(
                                  builder: (context) {
                                    if (upcomingMatch[2][0] == teamNum ||
                                        upcomingMatch[2][1] == teamNum ||
                                        upcomingMatch[2][2] == teamNum) {
                                      return Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.red,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Red Alliance",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "${upcomingMatch[2][0]} ${upcomingMatch[2][1]} ${upcomingMatch[2][2]}",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Red Alliance",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            Text(
                                              "${upcomingMatch[2][0]} ${upcomingMatch[2][1]} ${upcomingMatch[2][2]}",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${upcomingMatch[0]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const Text("VS"),
                                      Text("${upcomingMatch[1]}"),
                                    ],
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    if (upcomingMatch[3][0] == teamNum ||
                                        upcomingMatch[3][1] == teamNum ||
                                        upcomingMatch[3][2] == teamNum) {
                                      return Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.blue,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Blue Alliance",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "${upcomingMatch[3][0]} ${upcomingMatch[3][1]} ${upcomingMatch[3][2]}",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Blue Alliance",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Text(
                                              "${upcomingMatch[3][0]} ${upcomingMatch[3][1]} ${upcomingMatch[3][2]}",
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
