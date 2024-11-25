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
      allowJoin: json["allowJoin"] == true,
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

  void addMember() {}

  void removeMember() {}

  void changeAdmin() {}

  void joinTeamGroup() {}
}

Future<TeamGroup?> getUserTeamGroup(String userId) async {
  if (!FirebaseAuth.instance.currentUser!.emailVerified) return null;

  Database database = Database();
  ElapseUser user = elapseUserDecode(jsonEncode(await database.getUserInfo(userId)));
  if (user.groupID.isEmpty) return null;

  TeamGroup group = TeamGroup.fromJson((await database.getGroupInfo(user.groupID[0]))!);
  prefs.setString("teamGroup", jsonEncode(group.toJson()));
  return group;
}
