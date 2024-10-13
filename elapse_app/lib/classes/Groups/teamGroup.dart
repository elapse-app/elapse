// import 'package:elapse_app/classes/Miscellaneous/location.dart';
// import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/classes/Team/team.dart';

import 'dart:convert';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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
