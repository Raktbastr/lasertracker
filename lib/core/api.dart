import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveSessionData(Map<String, dynamic> data, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  
  await prefs.setString("loginGroupKey", data["join_key"] ?? "");
  await prefs.setString("loginUsername", data["username"] ?? "");
  await prefs.setString("loginPin", pin);

  await prefs.setString("team_number", data["team_number"].toString());
  await prefs.setString("group_name", data["group_name"] ?? "");
  await prefs.setString("event_key", data["event_key"] ?? "");
  await prefs.setString("join_key", data["join_key"] ?? "");

  await prefs.setString("member_id", data["id"].toString());
  await prefs.setString("username", data["username"] ?? "");
  await prefs.setString("display_name", data["display_name"] ?? "");
  await prefs.setString("status", data["status"] ?? "");
  await prefs.setString("job", data["job"] ?? "");
  await prefs.setString("role", data["role"] ?? "");
  await prefs.setString("location", data["location"] ?? "");
}

Future<bool> groupLogin(String groupKey, String username, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";

  final response = await http.post(
    Uri.parse("$serverURL/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"join_key": groupKey, "username": username, "pin": pin}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await _saveSessionData(data, pin);
    return true;
  } else {
    throw Exception(jsonDecode(response.body)["error"] ?? "Failed to login");
  }
}

Future<bool> memberAdd(String username, String displayName, String pin, String groupKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";

  final response = await http.post(
    Uri.parse("$serverURL/groups/join"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "join_key": groupKey,
      "username": username,
      "display_name": displayName,
      "pin": pin
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    await _saveSessionData(data, pin);
    return true;
  } else {
    throw Exception(jsonDecode(response.body)["error"] ?? "Failed to join group");
  }
}

Future<bool> groupCreate(String groupName, String eventKey, int teamNum, String username, String displayName, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";

  final response = await http.post(
    Uri.parse("$serverURL/groups"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": groupName,
      "event_key": eventKey,
      "team_number": teamNum,
      "leader_username": username,
      "leader_display_name": displayName,
      "leader_pin": pin
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    await _saveSessionData(data, pin);
    return true;
  } else {
    throw Exception(jsonDecode(response.body)["error"] ?? "Failed to create group");
  }
}

Future<String> getTeamName(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";
  
  final response = await http.get(Uri.parse("$serverURL/tba/teaminfo/$teamNum"));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["nickname"];
  }
  return "Unknown Team";
}

Future<Image> getTeamAvatar(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";

  final response = await http.get(Uri.parse("$serverURL/tba/avatar/$teamNum"));
  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    for (var item in data) {
      if (item["type"] == "avatar") {
        return Image.memory(base64Decode(item["details"]["base64Image"]));
      }
    }
  }
  return Image.asset("assets/first_icon.png"); // Make sure this asset exists
}

Future<List<dynamic>> getEvents(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";

  final response = await http.get(Uri.parse("$serverURL/tba/$teamNum/events"));
  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((event) => {event["name"]: event["key"]}).toList();
  }
  return [];
}

Future<List<dynamic>> getMatches(String teamNum, String eventKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL") ?? "https://api.lasertracker.laserrobotics.org";
  
  final response = await http.get(Uri.parse("$serverURL/tba/matches/$eventKey/$teamNum"));
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception("Failed to load matches");
  }
}