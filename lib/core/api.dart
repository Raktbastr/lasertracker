import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _saveSessionData(Map<String, dynamic> data, String pin) async {
  final prefs = await SharedPreferences.getInstance();

  if (data["id"] != null) {
    await prefs.setInt("member_id", data["id"] as int);
  }

  await prefs.setString("loginGroupKey", data["group_key"] ?? "");
  await prefs.setString("loginUsername", data["username"] ?? "");
  await prefs.setString("loginPin", pin);

  await prefs.setString("team_number", data["team_number"].toString());
  await prefs.setString("group_name", data["group_name"] ?? "");
  await prefs.setString("event_key", data["event_key"] ?? "");

  await prefs.setString("member_id", data["id"].toString());
  await prefs.setString("display_name", data["display_name"] ?? "");
  await prefs.setString("job", data["job"] ?? "");
  await prefs.setString("role", data["role"] ?? "");
  await prefs.setString("location", data["location"] ?? "");
}

Future<bool> groupLogin(String groupKey, String username, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.post(
    Uri.parse("$serverURL/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"group_key": groupKey, "username": username, "pin": pin}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    await _saveSessionData(data, pin);
    return true;
  } else {
    throw Exception("Failed to login: ${response.statusCode}");
  }
}

Future<bool> memberAdd(String username, String displayName, String pin, String groupKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.post(
    Uri.parse("$serverURL/groups/join"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"group_key": groupKey, "username": username, "display_name": displayName, "pin": pin}),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    await _saveSessionData(data, pin);
    return true;
  } else {
    throw Exception("Failed to join group: ${response.statusCode}");
  }
}

Future<bool> groupCreate(
  String groupName,
  String eventKey,
  String teamNum,
  String username,
  String displayName,
  String pin,
) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.post(
    Uri.parse("$serverURL/groups"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "name": groupName,
      "event_key": eventKey,
      "team_number": teamNum,
      "leader_username": username,
      "leader_display_name": displayName,
      "leader_pin": pin,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    await _saveSessionData(data, pin);
    return true;
  } else {
    throw Exception("Failed to create group: ${response.statusCode}");
  }
}

Future<String> getTeamName(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.get(Uri.parse("$serverURL/tba/teaminfo/$teamNum"));
  if (response.statusCode == 200) {
    return jsonDecode(response.body)["nickname"];
  }
  return "Unknown Team";
}

Future<Image> getTeamAvatar(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.get(Uri.parse("$serverURL/tba/avatar/$teamNum"));
  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    for (var item in data) {
      if (item["type"] == "avatar") {
        return Image.memory(base64Decode(item["details"]["base64Image"]));
      }
    }
  }
  return Image.asset("assets/first_icon.png");
}

Future<List<dynamic>> getEvents(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.get(Uri.parse("$serverURL/tba/$teamNum/events"));
  if (response.statusCode == 200) {
    List data = jsonDecode(response.body);
    return data.map((event) => {event["name"]: event["key"]}).toList();
  } else {
    throw Exception("Failed to load events: ${response.statusCode}");
  }
}

Future<List<dynamic>> getMatches(String teamNum, String eventKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");

  final response = await http.get(Uri.parse("$serverURL/tba/matches/$eventKey/$teamNum"));
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception("Failed to load matches: ${response.statusCode}");
  }
}

Future<bool> isAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final username = prefs.getString("loginUsername");
  final pin = prefs.getString("loginPin");
  final response = await http.get(
    Uri.parse("$serverURL/groups/$groupKey/admin-check"),
    headers: {"X-Username": username ?? "", "X-Pin": pin ?? ""},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body)["is_admin"] ?? false;
  }
  return false;
}

Future<List<dynamic>> getMembers() async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final username = prefs.getString("loginUsername");
  final pin = prefs.getString("loginPin");

  final response = await http.get(
    Uri.parse("$serverURL/groups/$groupKey/members"),
    headers: {"X-Username": username ?? "", "X-Pin": pin ?? ""},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception("Failed to fetch members: ${response.statusCode}");
  }
}

Future<bool> setStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final username = prefs.getString("loginUsername");
  final pin = prefs.getString("loginPin");
  final location = prefs.getString("location");
  final job = prefs.getString("job");

  final response = await http.put(
    Uri.parse("$serverURL/groups/$groupKey/members/status"),
    headers: {"Content-Type": "application/json", "X-Username": username ?? "", "X-Pin": pin ?? ""},
    body: jsonEncode({"location": location, "job": job}),
  );

  if (response.statusCode == 200) {
    prefs.setString("job", job ?? "");
    prefs.setString("location", location ?? "");
    return true;
  } else {
    throw Exception("Failed to update status: ${response.statusCode}");
  }
}

Future<bool> changePin(String targetUsername, String newPin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final currentUsername = prefs.getString("loginUsername");
  final currentPin = prefs.getString("loginPin");

  bool isSelf = currentUsername?.toLowerCase() == targetUsername.toLowerCase();
  bool adminStatus = await isAdmin();

  if (!isSelf && !adminStatus) {
    throw Exception("Unauthorized: You can only change your own pin unless you are an admin.");
  }

  final response = await http.put(
    Uri.parse("$serverURL/groups/$groupKey/members/$targetUsername/reset-pin"),
    headers: {"Content-Type": "application/json", "X-Username": currentUsername ?? "", "X-Pin": currentPin ?? ""},
    body: jsonEncode({"new_pin": newPin}),
  );

  if (response.statusCode == 200) {
    if (isSelf) {
      await prefs.setString("loginPin", newPin);
    }
    return true;
  } else {
    throw Exception("Failed to reset pin: ${response.statusCode}");
  }
}

Future<bool> changeRole(String targetUsername, String newRole) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final currentUsername = prefs.getString("loginUsername");
  final currentPin = prefs.getString("loginPin");

  bool adminStatus = await isAdmin();

  if (!adminStatus) {
    throw Exception("Unauthorized: You can only change roles as an admin.");
  }

  final response = await http.put(
    Uri.parse("$serverURL/groups/$groupKey/members/role"),
    headers: {
      "Content-Type": "application/json",
      "X-Username": currentUsername ?? "",
      "X-Pin": currentPin ?? "",
      "X-Target": targetUsername,
    },
    body: jsonEncode({"new_role": newRole}),
  );

  if (response.statusCode == 200) {
    bool isSelf = currentUsername?.toLowerCase() == targetUsername.toLowerCase();
    if (isSelf) {
      await prefs.setString("role", newRole);
    }
    return true;
  } else {
    throw Exception("Failed to change role: ${response.statusCode}");
  }
}

Future<bool> updateGroup(String groupName, String eventKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final currentUsername = prefs.getString("loginUsername");
  final currentPin = prefs.getString("loginPin");

  final response = await http.put(
    Uri.parse("$serverURL/groups/$groupKey"),
    headers: {"Content-Type": "application/json", "X-Username": currentUsername ?? "", "X-Pin": currentPin ?? ""},
    body: jsonEncode({"group_name": groupName, "event_key": eventKey}),
  );

  if (response.statusCode == 200) {
    await prefs.setString("group_name", groupName);
    await prefs.setString("event_key", eventKey);
    return true;
  } else {
    throw Exception("Failed to update group: ${response.statusCode}");
  }
}

Future<bool> changeAdmin(String targetUsername, bool status) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final currentUsername = prefs.getString("loginUsername");
  final currentPin = prefs.getString("loginPin");
  int admin;

  if (status) {
    admin = 1;
  } else {
    admin = 0;
  }

  final response = await http.put(
    Uri.parse("$serverURL/groups/$groupKey/members/change-admin"),
    headers: {
      "Content-Type": "application/json",
      "X-Username": currentUsername ?? "",
      "X-Pin": currentPin ?? "",
      "X-Target": targetUsername,
    },
    body: jsonEncode({"is_admin": admin}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception("Failed to update admin status: ${response.statusCode}");
  }
}

Future<List<dynamic>> getLogs() async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final groupKey = prefs.getString("loginGroupKey");
  final currentUsername = prefs.getString("loginUsername");
  final currentPin = prefs.getString("loginPin");

  final response = await http.get(
    Uri.parse("$serverURL/groups/$groupKey/logs"),
    headers: {"X-Username": currentUsername ?? "", "X-Pin": currentPin ?? ""},
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  } else {
    throw Exception("Failed to fetch logs: ${response.statusCode}");
  }
}

Future<List<dynamic>> getStream() async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final eventKey = prefs.getString("event_key");

  final response = await http.get(Uri.parse("$serverURL/tba/event/$eventKey/stream"));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  }

  return [];
}