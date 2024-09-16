import 'package:elapse_app/classes/Users/user.dart';
import 'package:random_string_generator/random_string_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

/* Users */
  Future<String> createUser(ElapseUser? newUser) async {
    String returnVal = 'monke';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String savedTeam = prefs.getString("savedTeam") ?? "";
      await _firestore.collection("users").doc(newUser?.uid).set({
        'email': newUser?.email,
        'firstName': newUser?.fname, // Changed to first name field later
        'lastName': newUser?.lname, // Changed to last name field later
        'team': jsonDecode(savedTeam)["teamNumber"],
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

/* Team Groups */

  // String AdminID, String groupName
  Future<String> createTeamGroup(
      String adminID, String gname, String firstName, String lastName) async {
    try {
      var alphanumericGenerator = RandomStringGenerator(
        fixedLength: 4,
        alphaCase: AlphaCase.UPPERCASE_ONLY,
        hasAlpha: true,
        hasDigits: true,
        hasSymbols: false,
        mustHaveAtLeastOneOfEach: true,
      );

      String joinCode = alphanumericGenerator.generate() +
          '-' +
          alphanumericGenerator.generate();
      Map<String, String> members = {adminID: "$firstName $lastName"};
      var group = await _firestore.collection('teamGroups').add({
        'adminId': adminID,
        'joinCode': joinCode,
        'team': "", // needs to be updated
        'members': members,
        'groupName': gname,
      });

      await _firestore.collection('users').doc(adminID).update({
        'groupId': FieldValue.arrayUnion([group.id]),
      });
      return group.id;
    } catch (e) {
      print(e);
    }
    return "unable to create";
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
        'members.$uid': firstName + " " + lastName,
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
}
