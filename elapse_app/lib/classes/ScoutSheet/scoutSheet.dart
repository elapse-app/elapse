// import 'package:elapse_app/classes/Miscellaneous/location.dart';
// import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elapse_app/classes/Team/team.dart';

import 'dart:convert';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';



// so then an example of properties could look like [{"drivetrain_rpm": 450, "type": "num"}, {"number_of_motors": 6, "type": "num"}]
// [11:31 PM]
// teamNotes - a long string where users can enter notes for a team (edited)
// [11:32 PM]
// gameNotes - a list containing JSONs in the form {"game_number": "note"}

class ScoutSheet {
  // Comp Specific stuff
  String? teamID;
  String? tournamentID;

  // User Related Stuff
  String? adminID;
  String? teamGroupID; // Optional Value

  // Timestamp Stuff
  DateTime? createTime;
  DateTime? latestUpdate;

  // List of the properties of the scouted robot
  Map<String, Map<String, Object>> properties = {};

  // Notes about the team & match
  String? teamNotes;
  String? gameNotes;

  // List of the URLs for any pictures
  List<String> photos = [];

  // Bool For currently Editing
  bool isEditing = false;


  // ScoutSheet({

  // });

}