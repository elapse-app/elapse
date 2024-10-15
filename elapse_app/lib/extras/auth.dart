import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../classes/Groups/teamGroup.dart';

Future<String?> signUp(String email, String password) async {
  try {
    // Create user with email and password
    // Check if email already exists before creating an account
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (methods.isNotEmpty) {
      return "email-already-in-use";
    }
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return "success";
  } on FirebaseAuthException catch (e) {
    print(e.message);
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
  print('authSucc - signed in user with uuid: ${user?.uid}');
  Database database = Database();
  Map<String, dynamic>? userInfo = await database.getUserInfo(user!.uid);
  print(userInfo);
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
    Map<String, dynamic>? group = await database.getGroupInfo(userInfo["groupId"][0]);
    final teamGroup = TeamGroup.fromJson(group!);
    teamGroup.groupId = userInfo["groupId"][0];
    prefs.setString("teamGroup", jsonEncode(teamGroup.toJson()));
  }

  prefs.setString("currentUser", jsonEncode(currentUser.toJson()));
  prefs.setString("savedTeam", jsonEncode(userInfo["team"]));
}
