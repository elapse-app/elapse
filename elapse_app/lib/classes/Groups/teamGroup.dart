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
  Team? team;

  // Members of the Team Group
  List<String> members = [];

  TeamGroup({
    required this.groupId,
    required this.adminId,
    required this.team,
    this.groupName,
  });


  // factory TeamGroup() {

  // }


  void addMember() {

  }

  void removeMember() {

  }

  void changeAdmin() {

  }

  void joinTeamGroup() {

  }









}
