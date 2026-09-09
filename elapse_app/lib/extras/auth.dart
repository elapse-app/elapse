import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/main.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../classes/Groups/teamGroup.dart';

Future<String?> signUp(String email, String password) async {
  try {
    // Create user with email and password
    // Check if email already exists before creating an account
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return "success";
  } on FirebaseAuthException catch (e) {
    debugPrint('Account creation failed: ${e.code}');
    return e.code;
  }
}

Future<void> signIN(String email, String password) async {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final User? user = credential.user;
  // Add to the Database
  Database database = Database();
  Map<String, dynamic>? userInfo = await database.getUserInfo(user!.uid);
  if (userInfo == null) {
    throw Exception("No user in database");
  }

  ElapseUser currentUser = ElapseUser(
    uid: user.uid,
    email: userInfo["email"],
    fname: userInfo["firstName"],
    lname: userInfo["lastName"],
    teamNumber: userInfo["team"]["teamNumber"],
    verified: userInfo["verified"],
  );
  if (userInfo["groupId"].isNotEmpty) {
    Map<String, dynamic>? group =
        await database.getGroupInfo(userInfo["groupId"][0]);
    final teamGroup = TeamGroup.fromJson(group!);
    currentUser.groupID.add(userInfo["groupId"][0]);
    teamGroup.groupId = userInfo["groupId"][0];
    prefs.setString("teamGroup", jsonEncode(teamGroup.toJson()));
  }

  prefs.setString("currentUser", jsonEncode(currentUser.toJson()));
  prefs.setString("savedTeam", jsonEncode(userInfo["team"]));
}

void clearPrefs() {
  prefs.remove("currentUser");
  prefs.remove("savedTeam");
  prefs.remove("savedTeams");
  prefs.remove("isTournamentMode");
  prefs.remove("teamGroup");

  prefs.setBool("isSetUp", false);
}

Future<bool> checkAccountDeleted() async {
  try {
    IdTokenResult? idToken =
        await FirebaseAuth.instance.currentUser?.getIdTokenResult(true);

    if (idToken == null || idToken.token == null) {
      debugPrint('The signed-in account is no longer available.');
      clearPrefs();
      await FirebaseAuth.instance.signOut();
      return true;
    }
  } on FirebaseAuthException catch (e) {
    const invalidAccountCodes = {
      'user-disabled',
      'user-not-found',
      'invalid-user-token',
      'user-token-expired',
    };
    if (invalidAccountCodes.contains(e.code)) {
      clearPrefs();
      await FirebaseAuth.instance.signOut();
      return true;
    }
    // Connectivity and service errors must not sign a user out or discard
    // their locally cached app state.
    debugPrint('Account verification deferred: ${e.code}');
  } catch (error) {
    debugPrint('Account verification deferred: $error');
  }
  return false;
}
