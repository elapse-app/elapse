import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/classes/Groups/teamGroup.dart';
import 'package:elapse_app/classes/Team/team.dart';

import 'dart:convert';
import 'package:elapse_app/extras/token.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class User {
  // User Class
  String? uid;
  String? email;
  String? fname;
  String? lname;
  // Team of the Team Group
  String? teamNumber;

  // Members of the Team Group
  List<String> groupID = [];

  // FirebaseAuth auth = FirebaseAuth.instance;

  User({
    required this.uid,
    required this.email,
    this.fname,
    this.lname,
    this.teamNumber,
  });

}