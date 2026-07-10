import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> getServerInfo() async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.get(Uri.parse("$serverURL/info"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch server info: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in getServerInfo: $e");
    rethrow;
  }
}

Future<Image> getTeamAvatar(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.get(Uri.parse("$serverURL/tba/avatar/$teamNum"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List && data.isNotEmpty) {
        final first = data.first;
        if (first is Map<String, dynamic> &&
            first['type'] == 'avatar' &&
            first['details'] is Map &&
            first['details']['base64Image'] is String) {
          final base64Image = first['details']['base64Image'] as String;
          return Image.memory(base64Decode(base64Image));
        }
      }
      return Image.asset('assets/first_icon.png');
    } else {
      throw Exception("Failed to fetch team avatar: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in getTeamAvatar: $e");
    debugPrint(serverURL);
    return Image.asset('assets/first_icon.png');
  }
}

Future<String> getTeamName(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.get(Uri.parse("$serverURL/tba/teaminfo/$teamNum"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["nickname"];
    } else {
      throw Exception("Failed to fetch team info: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in getTeamName: $e");
    return "Team Name";
  }
}

Future<List<dynamic>> getEvents(String teamNum) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.get(Uri.parse("$serverURL/tba/$teamNum/events"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> events = [];
      for (var event in data) {
        events.add({event["name"]: event["key"]});
      }
      return events;
    } else {
      throw Exception("Failed to fetch team matches: ${response.statusCode}");
    }
  } catch(e) {
    debugPrint("Error in getMatches: $e");
    rethrow;
  }
}

Future<List<dynamic>> getMatches(String teamNum, String eventKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.get(Uri.parse("$serverURL/tba/$teamNum/events/$eventKey"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception("Failed to fetch team matches: ${response.statusCode}");
    }
  } catch(e) {
    debugPrint("Error in getMatches: $e");
    rethrow;
  }
}

Future<bool> groupLogin(String groupKey, String username, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.post(
      Uri.parse("$serverURL/login"),
      headers: <String, String>{"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode(<String, dynamic>{
        "join_key": groupKey,
        "username": username,
        "pin": pin
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      prefs.setInt("member_id", data["member_id"]);
      prefs.setInt("group_id", data["group_id"]);
      prefs.setString("group_name", data["group_name"]);
      prefs.setString("event_key", data["event_key"]);
      prefs.setInt("team_number", data["team_number"]);
      prefs.setString("display_name", data["display_name"]);
      prefs.setString("job", data["job"]);
      prefs.setString("role", data["role"]);
      prefs.setString("location", data["location"]);

      prefs.setString("loginGroupKey", groupKey);
      prefs.setString("loginUsername", username);
      prefs.setString("loginPin", pin);

      return true;
    } else {
      throw Exception("Failed to login. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in groupLogin: $e");
    rethrow;
  }
}

Future<bool> groupCreate(String groupName, String eventKey, int teamNum, String username, String displayName, String pin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.post(
      Uri.parse("$serverURL/groups"),
      headers: <String, String>{"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode(<String, dynamic>{
        "name": groupName,
        "event_key": eventKey,
        "team_number": teamNum,
        "leader_username": username,
        "leader_display_name": displayName,
        "leader_pin": pin
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      prefs.setInt("group_id", data["group_id"]);
      prefs.setInt("leader_id", data["leader_id"]);
      prefs.setInt("member_id", data["leader_id"]);

      prefs.setString("loginGroupKey", data["join_key"]);
      prefs.setString("loginUsername", username);
      prefs.setString("loginPin", pin);
      
      return true;
    } else if (response.statusCode == 409) {
      throw Exception("Failed to create member. Member already created in group");
    } else {
      throw Exception("Failed to create member. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in groupCreate: $e");
    rethrow;
  }
}

Future<bool> memberAdd(String username, String displayName, String pin, String groupKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  try {
    final response = await http.post(
      Uri.parse("$serverURL/groups/join"),
      headers: <String, String>{"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode(<String, dynamic>{
        "join_key": groupKey,
        "username": username,
        "display_name": displayName,
        "pin": pin
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      prefs.setInt("member_id", data["member_id"]);
      prefs.setInt("group_id", data["group_id"]);

      prefs.setString("loginGroupKey", groupKey);
      prefs.setString("loginUsername", username);
      prefs.setString("loginPin", pin);
      return true;
    } else if (response.statusCode == 409) {
      throw Exception("Failed to create member. Member already created in group");
    } else {
      throw Exception("Failed to create member. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in memberAdd: $e");
    rethrow;
  }
}

Future<bool> updateGroup(String joinKey, String groupName, String eventKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final memberId = prefs.getInt("member_id");

  try {
    final response = await http.put(
      Uri.parse("$serverURL/groups/$joinKey"),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
        "X-Member-ID": memberId.toString(),
      },
      body: jsonEncode(<String, dynamic>{
        "group_name": groupName,
        "event_key": eventKey,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to update group. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in updateGroup: $e");
    rethrow;
  }
}

Future<bool> resetMemberPin(String joinKey, int targetMemberId, String newPin) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final leaderId = prefs.getInt("member_id");

  try {
    final response = await http.put(
      Uri.parse("$serverURL/groups/$joinKey/members/$targetMemberId/reset-pin"),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
        "X-Member-ID": leaderId.toString(),
      },
      body: jsonEncode(<String, dynamic>{
        "new_pin": newPin,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to reset pin. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in resetMemberPin: $e");
    rethrow;
  }
}

Future<List<dynamic>> getMembers(String joinKey) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final username = prefs.getString("username") ?? "";
  final pin = prefs.getString("pin") ?? "";

  try {
    final response = await http.get(
      Uri.parse("$serverURL/groups/$joinKey/members"),
      headers: <String, String>{
        "X-Username": username,
        "X-Pin": pin,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get members. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in getMembers: $e");
    rethrow;
  }
}

Future<Map<String, dynamic>> updateMemberStatus(String joinKey, {String? status, String? job, String? role, String? location}) async {
  final prefs = await SharedPreferences.getInstance();
  final serverURL = prefs.getString("backendURL");
  final username = prefs.getString("username") ?? "";
  final pin = prefs.getString("pin") ?? "";

  Map<String, dynamic> bodyPayload = {};
  if (status != null) bodyPayload["status"] = status;
  if (job != null) bodyPayload["job"] = job;
  if (role != null) bodyPayload["role"] = role;
  if (location != null) bodyPayload["location"] = location;

  try {
    final response = await http.put(
      Uri.parse("$serverURL/groups/$joinKey/members/status"),
      headers: <String, String>{
        "Content-Type": "application/json; charset=UTF-8",
        "X-Username": username,
        "X-Pin": pin,
      },
      body: jsonEncode(bodyPayload),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (status != null) prefs.setString("status", data["status"]);
      if (job != null) prefs.setString("job", data["job"]);
      if (role != null) prefs.setString("role", data["role"]);
      if (location != null) prefs.setString("location", data["location"]);
      
      return data;
    } else {
      throw Exception("Failed to update status. Status code: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error in updateMemberStatus: $e");
    rethrow;
  }
}