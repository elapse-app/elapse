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

import '../classes/Groups/teamGroup.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

/* Users */
  Future<String?> createUser(ElapseUser? newUser, TeamPreview savedTeam) async {
    try {
      // SharedPreferences prefs = await SharedPreferences.getInstance(); // Might be useful at some point
      await _firestore.collection("users").doc(newUser?.uid).set({
        'email': newUser?.email,
        'firstName': newUser?.fname, // Changed to first name field later
        'lastName': newUser?.lname, // Changed to last name field later
        'team': savedTeam.toJson(),
        'groupId': [],
        'verified': false
      });
      return newUser?.uid;
    } catch (e) {
      print(e);
    }
    return null;
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

  Future<void> deleteUser(String uid) async {
    try {
      String? uid = auth.currentUser?.uid;
      // Remove from all team groups
      var snapshot = await _firestore.collection('users').doc(uid).get();

      List<dynamic> groups = snapshot.get('groupId');

      for (int x = 0; x < groups.length; x++) {
        print(groups[x]);
        await leaveTeamGroup(groups[x], uid!);
      }

      // Delete UID from Users doc
      await _firestore.collection('users').doc(uid).delete();

      // Delete User Account
      await auth.currentUser?.delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteCurrentUser() async {
    deleteUser(FirebaseAuth.instance.currentUser!.uid);
  }

  Future<void> verifyUser(String uid) async {
    try {
      var user = await _firestore.collection('users').doc(uid).get();
      user.reference.update({'verified': true});
    } catch (e) {
      print(e);
    }
  }

/* Team Groups */

  // String AdminID, String groupName
  Future<TeamGroup?> createTeamGroup(
      String adminID, String gname, String fname, String lname) async {
    try {
      var alphanumericGenerator = RandomStringGenerator(
        fixedLength: 4,
        alphaCase: AlphaCase.UPPERCASE_ONLY,
        hasAlpha: true,
        hasDigits: true,
        hasSymbols: false,
        mustHaveAtLeastOneOfEach: true,
      );

      String joinCode = '${alphanumericGenerator.generate()}-${alphanumericGenerator.generate()}';
      Map<String, String> members = {adminID: "$fname $lname"};
      var group = await _firestore.collection('teamGroups').add({
        'adminId': adminID,
        'joinCode': joinCode,
        'allowJoin': true,
        'members': members,
        'groupName': gname,
      });

      await _firestore.collection('users').doc(adminID).update({
        'groupId': FieldValue.arrayUnion([group.id]),
      });

      return TeamGroup(
          groupId: group.id,
          groupName: gname,
          adminId: adminID,
          joinCode: joinCode,
          allowJoin: true,
          members: members);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<TeamGroup?> joinTeamGroup(String joinCode, String uid) async {
    var Data = await getUserInfo(uid);
    try {
      // Get the Users Name
      String firstName = Data!['firstName'];
      String lastName = Data['lastName'];

      // Get the Team Group Document from joinCode and add user to list of members
      var teamDoc = await _firestore.collection('teamGroups').where('joinCode', isEqualTo: joinCode).limit(1).get();
      DocumentSnapshot? userDoc = teamDoc.docs.first;
      userDoc.reference.update({
        'members.$uid': "$firstName $lastName",
      });
      // Update the users list of team groups
      await _firestore.collection('users').doc(uid).update({
        'groupId': FieldValue.arrayUnion([userDoc.reference.id]),
      });

      Map<String, String> members = userDoc.get("members").map<String, String>((key, val) => MapEntry(key.toString(), val.toString()));
      members.addAll({uid: "$firstName $lastName"});

      return TeamGroup(
        groupId: userDoc.id,
        groupName: userDoc.get("groupName"),
        adminId: userDoc.get("adminId"),
        joinCode: joinCode,
        allowJoin: userDoc.get("allowJoin"),
        members: members,
      );
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> deleteTeamGroup(String groupId) async {
    try {
      var group = await _firestore.collection('teamGroups').doc(groupId).get();
      final members = group.data()?["members"];
      List<Future<void>> memberFutures = [];
      for (final id in members.keys) {
        memberFutures.add(_firestore.collection('users').doc(id).update({'groupId': FieldValue.arrayRemove([groupId])}));
      }
      await Future.wait(memberFutures);
      await _firestore.collection('teamGroups').doc(groupId).delete();
    } catch(e) {
      print(e);
    }
  }

  Future<void> leaveTeamGroup(String groupid, String memberid) async {
    try {
      await _firestore.collection('teamGroups').doc(groupid).update({
        'members.$memberid': FieldValue.delete(),
      });
      var info = await _firestore.collection('teamGroups').doc(groupid).get();
      if (info.get("members").isEmpty) {
        await deleteTeamGroup(groupid);
      } else if (info.get("adminId") == memberid) {
        await _firestore.collection('teamGroups').doc(groupid).update({
          'adminId': info.get("members").keys.toList()[0],
        });
      }

      await _firestore.collection('users').doc(memberid).update({
        'groupId': FieldValue.arrayRemove([groupid]),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> removeMember(String groupid, String memberID) async {
    try {
      await _firestore.collection('teamGroups').doc(groupid).update({
        'members.$memberID': FieldValue.delete(),
      });
      await _firestore.collection('users').doc(memberID).update({
        'groupId': FieldValue.arrayRemove([groupid]),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> promoteNewAdmin(String groupID, String uid, String memberID) async {
    try {
      await _firestore.collection('teamGroups').doc(groupID).update({
        'adminId': memberID,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateGroupName(String groupID, String groupName) async {
    try {
      await _firestore.collection('teamGroups').doc(groupID).update({'groupName': groupName});
    } catch(e) {
      print(e);
    }
  }

  Future<void> updateAllowJoin(String groupID, bool allowJoin) async {
    try {
      await _firestore.collection('teamGroups').doc(groupID).update({'allowJoin': allowJoin});
    } catch(e) {
      print(e);
    }
  }

  Future<String?> generateNewJoinCode(String groupID) async {
    try {
      var alphanumericGenerator = RandomStringGenerator(
        fixedLength: 4,
        alphaCase: AlphaCase.UPPERCASE_ONLY,
        hasAlpha: true,
        hasDigits: true,
        hasSymbols: false,
        mustHaveAtLeastOneOfEach: true,
      );
      String newCode = "${alphanumericGenerator.generate()}-${alphanumericGenerator.generate()}";

      await _firestore.collection('teamGroups').doc(groupID).update({'joinCode': newCode});
      return newCode;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> clearScoutsheets(String groupID) async {
    try {
      var scoutsheets = await _firestore.collection('teamGroups').doc(groupID).collection('scoutsheets').get();
      scoutsheets.docs.first.reference.delete();
    } catch(e) {
      print(e);
    }
  }

  Future<void> clearMatchNotes(String groupID) async {
    try {
      var matchNotes = await _firestore.collection('teamGroups').doc(groupID).collection('matchNotes').get();
      matchNotes.docs.first.reference.delete();
    } catch(e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?> getGroupInfo(String groupid) async {
    try {
      var collection = await _firestore.collection('teamGroups').doc(groupid).get();
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

  Future<String> createTeamScoutSheet(String teamGroupID, String teamid, String tournamentID) async {
    String returnVal = '';
    try {
      await _firestore.collection('teamGroups').doc(teamGroupID).collection('scoutsheets').add({
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
          "Specs": {"dbMotors": "", "dbRPM": "", "intakeType": "", "otherNotes": ""},
        },
        // Picklist
        // 'picklist': {
        //   'teams': [],
        //   'tournamentId': "",
        // },
        // Notes about the team & match
        'teamNotes': "",
        'gameNotes': "",
        // List of the URLs for any pictures
        'photos': [],
        // Bool for Currently Editing and Ablility to Join?
        'isEditing': false,
        'allowJoin': false, // Not sure why this is here anymore tbh
      }).then((onValue) {
        returnVal = onValue.id;
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<void> removeTeamScoutSheet(String teamid, String teamGroupID, String tournamentID) async {
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
  }

  Future<void> updateMemberEditing(String teamGroupId, String teamID, String tournamentID, bool Val) async {
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
  }

  Future<List?>? getAllTeamScoutSheets(String teamGroupId) async {
    try {
      var collection = await _firestore.collection('teamGroups').doc(teamGroupId).collection('scoutsheets').get();
      return collection.docs.toList(); // Unchecked
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<List?>? getTeamScoutSheetPerCompetition(String teamGroupId, String tournamentID) async {
    try {
      var collection = await _firestore
          .collection('teamGroups')
          .doc(teamGroupId)
          .collection('scoutsheets')
          .where('tournamentID', isEqualTo: tournamentID)
          .get();
      return collection.docs.toList(); // Unchecked
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<DocumentSnapshot?> getTeamScoutSheetInfo(String teamGroupId, String teamID, String tournamentID) async {
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

  Future<Map<String, dynamic>?> updateProperty(
      String teamGroupId, String teamID, String tournamentID, String property, dynamic val) async {
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

  Future<Map<String, dynamic>?> updateTeamNotes(
      String teamGroupId, String teamID, String tournamentID, String notes) async {
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

  Future<Map<String, dynamic>?> addPhoto(String teamGroupId, String teamID, String tournamentID, String url) async {
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
        'properties.Specs.photos': FieldValue.arrayUnion([url]),
      });
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> deletePhoto(String teamGroupId, String teamID, String tournamentID, String URL) async {
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
    final imagesRef = storage
        .ref()
        .child("elapse-images/${DateTime.now().millisecondsSinceEpoch}.jpg"); // add a unique name for each file
    try {
      final uploadTask = await imagesRef.putFile(image);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      print('File uploaded at: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
    }
    return "";
  }

/* ------------------------------ */
/*         User ScoutSheet        */
/* ------------------------------ */

  Future<void> createUserScoutSheet(String uid, String teamid, String tournamentID) async {
    try {
      await _firestore.collection('Users').doc(uid).collection('scoutsheets').doc().set({
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
        // Picklist
        // 'picklist': {
        //   'teams': [],
        //   'tournamentId': "",
        // },
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
  }

  Future<Map<String, dynamic>?> getUserScoutSheetInfo(String uid, String teamID, String tournamentID) async {
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


/* ------------------------------ */
/*          Team Picklist         */
/* ------------------------------ */

// Make a copy constructor to make teams/users easily able to share via QR CODE
// Add Realtime Listener

  Future<String> createTeamPicklist(String teamGroupID, String teamid, String tournamentID) async {
    String returnVal = '';
    try {
      await _firestore.collection('teamGroups').doc(teamGroupID).collection('picklist').add({
        /* Made with creation */
        // List of potential teams
        'teams': [],
        // Tourny ID
        'tournamentID': tournamentID,

        // Timestamp Stuff
        'createTime': DateTime.now(),

        /* Updated with Editing */
        'latestUpdate': null,

        // Bool for Currently Editing
        'isEditing': false,
      }).then((onValue) {
        returnVal = onValue.id;
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }
}
