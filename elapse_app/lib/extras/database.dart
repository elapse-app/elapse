import 'dart:io';

import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Users/user.dart';
import 'package:flutter/rendering.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

/* Users */
  Future<String> createUser(ElapseUser? newUser, TeamPreview savedTeam) async {
    String returnVal = 'monke';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await _firestore.collection("users").doc(newUser?.uid).set({
        'email': newUser?.email,
        'firstName': newUser?.fname, // Changed to first name field later
        'lastName': newUser?.lname, // Changed to last name field later
        'team': savedTeam.toJson(),
        'groupId': []
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    try {
      var collection = await _firestore.collection('users').doc(uid).get();
      return collection.data();
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> deleteUser(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> deleteCurrentUser() async {
    try {
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .delete();
    } catch (e) {
      print(e);
    }
    return "";
  }

/* Team Groups */

  // String AdminID, String groupName
  Future<String> createTeamGroup(String adminID, String gname, String teamid,
      String fname, String lname) async {
    String returnVal = 'hello';
    try {
      var alphanumericGenerator = RandomStringGenerator(
        fixedLength: 4,
        alphaCase: AlphaCase.UPPERCASE_ONLY,
        hasAlpha: true,
        hasDigits: true,
        hasSymbols: false,
        mustHaveAtLeastOneOfEach: true,
      );

      String joinCode =
          '${alphanumericGenerator.generate()}-${alphanumericGenerator.generate()}';
      Map<String, String> members = {adminID: "$fname $lname"};
      var group = await _firestore.collection('teamGroups').add({
        'adminId': adminID,
        'joinCode': joinCode,
        'team': teamid, // needs to be updated
        'members': members,
        'groupName': gname,
      });

      await _firestore.collection('users').doc(adminID).update({
        'groupId': FieldValue.arrayUnion([group.id]),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> joinTeamGroup(String joinCode, String uid) async {
    String returnVal = 'hello';
    var Data = await getUserInfo(uid);
    try {
      // Get the Users Name
      String firstName = Data!['firstName'];
      String lastName = Data['lastName'];

      // Get the Team Group Document from joinCode and add user to list of members
      var teamDoc = await _firestore
          .collection('teamGroups')
          .where('joinCode', isEqualTo: joinCode)
          .limit(1)
          .get();
      DocumentSnapshot? userDoc = teamDoc.docs.first;
      userDoc.reference.update({
        'members.$uid': "$firstName $lastName",
      });
      // Update the users list of team groups
      await _firestore.collection('users').doc(uid).update({
        'groupId': FieldValue.arrayUnion([userDoc.reference.id]),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> leaveTeamGroup(String groupid, String memberid) async {
    String returnVal = 'hello';
    try {
      await _firestore.collection('teamGroups').doc(groupid).update({
        'members.$memberid': FieldValue.delete(),
      });
      await _firestore.collection('users').doc(memberid).update({
        'groupId': FieldValue.arrayUnion([groupid]),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> removeMember(String groupid, String memberID) async {
    String returnVal = 'hello';
    try {
      await _firestore.collection('teamGroups').doc(groupid).update({
        'members.$memberID': FieldValue.delete(),
      });
      await _firestore.collection('users').doc(memberID).update({
        'groupId': FieldValue.arrayUnion([groupid]),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> promoteNewAdmin(
      String groupID, String uid, String memberID) async {
    String returnVal = 'hello';
    try {
      await _firestore.collection('teamGroups').doc(groupID).update({
        'adminId': memberID,
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<Map<String, dynamic>?> getGroupInfo(String groupid) async {
    try {
      var collection =
          await _firestore.collection('teamGroups').doc(groupid).get();
      return collection.data();
    } catch (e) {
      print(e);
    }
    return null;
  }

/* ------------------------------ */
/*         Team ScoutSheet        */
/* ------------------------------ */

// Make a copy constructor to make teams/users easily able to share via QR CODE
// Add Realtime Listener

  Future<String> createTeamScoutSheet(
      String teamGroupID, String teamid, String tournamentID) async {
    String returnVal = '';
    try {
      await _firestore
          .collection('teamGroups')
          .doc(teamGroupID)
          .collection('scoutsheets')
          .add({
        /* Made with creation */
        // Comp Specific stuff
        'teamID': teamid,
        'tournamentID': tournamentID,

        // Timestamp Stuff
        'createTime': DateTime.now(),

        /* Updated with Editing */
        'latestUpdate': null,
        // List of the properties of the scouted robot
        'properties': {
          "Specs": {
            "dbMotors": "",
            "dbRPM": "",
            "intakeType": "",
            "otherNotes": ""
          },
          "photos": []
        },
        // Notes about the team & match
        'teamNotes': "",
        'gameNotes': "",
        // List of the URLs for any pictures
        'photos': [],
        // Bool for Currently Editing and Ablility to Join
        'isEditing': false,
        'allowJoin': false,
      }).then((onValue) {
        returnVal = onValue.id;
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> removeTeamScoutSheet(
      String teamid, String teamGroupID, String tournamentID) async {
    String returnVal = 'hello';
    try {
      var scoutSheetCollection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupID)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamid)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      DocumentSnapshot? collection = scoutSheetCollection.docs.first;
      collection.reference.delete();
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> updateMemberEditing(
      String teamGroupId, String teamID, String tournamentID, bool Val) async {
    String returnVal = "";
    try {
      var scoutSheetCollection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      DocumentSnapshot? collection = scoutSheetCollection.docs.first;
      collection.reference.update({
        'isEditing': Val,
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<List?>? getAllTeamScoutSheets(
      String teamGroupId, String teamID, String tournamentID) async {
    try {
      var collection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .get();
      return collection.docs.toList(); // Unchecked
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<DocumentSnapshot?> getTeamScoutSheetInfo(
      String teamGroupId, String teamID, String tournamentID) async {
    try {
      var collection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      return collection.docs.first;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateProperty(String teamGroupId,
      String teamID, String tournamentID, String property, dynamic val) async {
    // Will probably need to be changed
    try {
      var scoutSheetCollection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      DocumentSnapshot? collection = scoutSheetCollection.docs.first;
      collection.reference.update({
        'properties.$property': val,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateTeamNotes(String teamGroupId,
      String teamID, String tournamentID, String notes) async {
    // Will probably need to be changed
    try {
      var scoutSheetCollection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      DocumentSnapshot? collection = scoutSheetCollection.docs.first;
      collection.reference.update({
        'teamNotes': notes,
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> addPhoto(String teamGroupId, String teamID,
      String tournamentID, String URL) async {
    // Will probably need to be changed
    try {
      var scoutSheetCollection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      DocumentSnapshot? collection = scoutSheetCollection.docs.first;
      collection.reference.update({
        'properties.Specs.photos': FieldValue.arrayUnion([URL]),
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> deletePhoto(String teamGroupId, String teamID,
      String tournamentID, String URL) async {
    // Will probably need to be changed
    try {
      var scoutSheetCollection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      DocumentSnapshot? collection = scoutSheetCollection.docs.first;
      collection.reference.update({
        'properties.Specs.photos': FieldValue.arrayRemove([URL]),
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> uploadPhoto(File image) async {
    final imagesRef = storage.ref().child(
        "elapse-images/${DateTime.now().millisecondsSinceEpoch}.jpg"); // add a unique name for each file
    try {
      final uploadTask = await imagesRef.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('File uploaded at: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
    }
  }

/* ------------------------------ */
/*         User ScoutSheet        */
/* ------------------------------ */

  Future<String> createUserScoutSheet(
      String uid, String teamid, String tournamentID) async {
    String returnVal = 'hello';
    try {
      await _firestore
          .collection('Users')
          .doc(uid)
          .collection('scoutsheets')
          .doc()
          .set({
        /* Made with creation */
        // Comp Specific stuff
        'teamID': teamid,
        'tournamentID': tournamentID,

        // Timestamp Stuff
        'createTime': DateTime.now(),

        /* Updated with Editing */
        'latestUpdate': DateTime,
        // List of the properties of the scouted robot
        'properties': {},
        // Notes about the team & match
        'teamNotes': "",
        'gameNotes': {},
        // List of the URLs for any pictures
        'photos': [],
        // Bool For currently Editing // Not Necesary since only 1 user
        // 'isEditing': false,
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<Map<String, dynamic>?> getUserScoutSheetInfo(
      String uid, String teamID, String tournamentID) async {
    try {
      var collection = await _firestore
          .collection('Users')
          .doc(uid)
          .collection('scoutsheets')
          .where('teamID', isEqualTo: teamID)
          .where('tournamentID', isEqualTo: tournamentID)
          .limit(1)
          .get();
      return collection.docs.first.data();
    } catch (e) {
      print(e);
    }
    return null;
  }
}
