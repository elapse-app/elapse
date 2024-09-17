import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/classes/Groups/teamGroup.dart';
import 'package:elapse_app/classes/Team/team.dart';

import 'dart:convert';
import 'package:elapse_app/extras/token.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ElapseUser {
  // User Class
  String? uid;
  String? email;
  String? fname;
  String? lname;
  // Team of the Team Group
  String? teamNumber;
  String? age;

  // Members of the Team Group
  List<String> groupID = [];

  // FirebaseAuth auth = FirebaseAuth.instance;

  ElapseUser(
      {required this.uid,
      required this.email,
      this.fname,
      this.lname,
      this.teamNumber,
      this.age});

  Map<String, dynamic> toJson() {
    return {
      "uid": this.uid,
      "email": this.email,
      "first-name": this.fname,
      "last-name": this.lname,
      "team-number": this.teamNumber,
      "age": this.age
    };
  }
}

ElapseUser elapseUserDecode(String json) {
  Map<String, dynamic> map = jsonDecode(json);
  return ElapseUser(
      uid: map["uid"],
      email: map["email"],
      fname: map["first-name"],
      lname: map["last-name"],
      teamNumber: map["team-number"],
      age: map["age"]);
}
