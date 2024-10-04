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

  // Team of the Team Group
  String teamNumber;

  // Members of the Team Group
  Map<String, String> members;

  TeamGroup({
    required this.groupId,
    required this.adminId,
    required this.teamNumber,
    required this.members,
    this.groupName,
  });

  factory TeamGroup.fromJson(Map<String, dynamic> json) {
    return TeamGroup(
      groupName: json["groupName"],
      groupId: json["groupId"],
      adminId: json["adminId"],
      teamNumber: json["teamNumber"],
      members: json["members"].map<String, String>((key, val) => MapEntry(key.toString(), val.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "groupName": groupName,
      "groupId": groupId,
      "adminId": adminId,
      "teamNumber": teamNumber,
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
