// import 'package:elapse_app/classes/Miscellaneous/location.dart';
// import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Users/user.dart';

import 'dart:convert';
import 'package:elapse_app/extras/token.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import '../../extras/database.dart';
import '../../main.dart';

class TeamGroup {
  // Name of the Team Group
  String? groupName;
  // ID of Team Group (Alpha Numeric String) and UID of Designated Admin
  String? groupId;
  String? adminId;

  // Members of the Team Group
  Map<String, String> members;

  bool allowJoin;
  String joinCode;

  TeamGroup({
    required this.groupId,
    required this.adminId,
    required this.members,
    required this.joinCode,
    this.groupName,
    this.allowJoin = true,
  });

  factory TeamGroup.fromJson(Map<String, dynamic> json) {
    print(json);
    return TeamGroup(
      groupName: json["groupName"],
      groupId: json["groupId"],
      adminId: json["adminId"],
      joinCode: json["joinCode"],
      allowJoin: json["allowJoin"],
      members: json["members"].map<String, String>((key, val) => MapEntry(key.toString(), val.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "groupName": groupName,
      "groupId": groupId,
      "adminId": adminId,
      "joinCode": joinCode,
      "allowJoin": allowJoin,
      "members": members,
    };
  }


  void addMember() {

  }

  void removeMember() {

  }

  void changeAdmin() {

  }

  void joinTeamGroup() {

  }
}

Future<TeamGroup?> getUserTeamGroup(String userId) async {
  final String? teamGroupData = prefs.getString("teamGroup");

  if (!FirebaseAuth.instance.currentUser!.emailVerified) return null;

  if (teamGroupData == null || !hasCachedTeamGroup(userId)) {
    Database database = Database();
    ElapseUser user = elapseUserDecode(jsonEncode(await database.getUserInfo(userId)));
    if (user.groupID.isEmpty) return null;

    TeamGroup group = TeamGroup.fromJson((await database.getGroupInfo(user.groupID[0]))!);
    prefs.setString("teamGroup", jsonEncode(group.toJson()));
    prefs.setString("teamGroupExpiry", DateTime.now().add(const Duration(minutes: 3)).toString());
    return group;
  }

  return TeamGroup.fromJson(jsonDecode(teamGroupData));
}

bool hasCachedTeamGroup(String userId) {
  if (userId != ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!)).uid) return false;

  final String? teamGroupData = prefs.getString("teamGroup");
  final String? expiryDate = prefs.getString("teamGroupExpiry");

  return teamGroupData != null &&
      expiryDate != null &&
      DateTime.parse(expiryDate).isAfter(DateTime.now());
}
