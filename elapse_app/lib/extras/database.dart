import 'package:random_string_generator/random_string_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class Database {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createUser(User? newUser) async {
    String returnVal = 'monke';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String savedTeam = prefs.getString("savedTeam") ?? "";
      await _firestore.collection("users").doc(newUser?.uid).set({
        'email': newUser?.email,
        'firstName': newUser?.displayName, // Changed to first name field later
        'lastName': newUser?.displayName, // Changed to last name field later
        'team': jsonDecode(savedTeam)["teamNumber"],
        'groupId': []
        // 'groupId': Map<String, dynamic>(),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<Map<String, dynamic>?> getUserInfo(String uid) async {
    // var Collection = await _firestore.collection('teamGroups').doc(groupID).get();
    // var Data = dude.data();
    // var what = Data?['members'];
    try {
      var collection = await _firestore.collection('users').doc(uid).get();
      return collection.data();
    } catch (e) {
      print(e);
    }
    return null;    
  }

  // String AdminID, String groupName
  Future<String> createTeamGroup(String adminID, String gname) async {
    String returnVal = 'hello';
    try {
      var alphanumericGenerator = RandomStringGenerator(
        fixedLength: 12,
        hasAlpha: true,
        hasDigits: true,
        hasSymbols: true,
        mustHaveAtLeastOneOfEach: true,
        customSymbols: ['-'],
      );
      String ID = alphanumericGenerator.generate();
      Map<String, String> members = {adminID: "Change to Full Name"};
      await _firestore.collection('teamGroups').doc(ID).set({
        'adminId': adminID,
        'team': "", // needs to be updated
        'members': members,
        'groupName': gname,
      });
      await _firestore.collection('users').doc(adminID).update({
        'groupId': FieldValue.arrayUnion([ID]),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  Future<String> joinTeamGroup(String groupID, String uid) async {
    String returnVal = 'hello';
    var Data = await getUserInfo(uid);
    try {
      // Get the Users Name
      String firstName = Data!['firstName'];
      String lastName = Data!['lastName'];

      await _firestore.collection('teamGroups').doc(groupID).update({
        'members.$uid': firstName + " " + lastName,
      });
      await _firestore.collection('users').doc(uid).update({
        'groupId': FieldValue.arrayUnion([groupID]),
      });
    } catch (e) {
      print(e);
    }
    return returnVal;
  }

  // Future<String> getMemberIdFromName(String memberName) async { // Not finished
  //   // Future<Map<String, dynamic>?> getUserInfo(String uid) async {
  //   String returnVal = "";
  //   // var Collection = await _firestore.collection('teamGroups').doc(groupID).get();
  //   // var Data = dude.data();
  //   // var what = Data?['members'];
  //   try {
  //     var collection = await _firestore.collection('users').doc(memberName).get();
  //     // return collection.data();
  //   } catch (e) {
  //     print(e);
  //   }

  //   return returnVal;    
  // }


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

  Future<String> promoteNewAdmin(String groupID, String uid, String memberID) async {
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
    // var Collection = await _firestore.collection('teamGroups').doc(groupID).get();
    // var Data = dude.data();
    // var what = Data?['members'];
    try {
      var collection = await _firestore.collection('teamGroups').doc(groupid).get();
      return collection.data();
    } catch (e) {
      print(e);
    }
    return null;    
  }

}