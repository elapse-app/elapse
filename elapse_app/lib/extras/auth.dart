import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> signUp(String email, String password, bool cancel) async {
  try {
    // Create user with email and password
    // Check if email already exists before creating an account
    final methods =
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    if (methods.isNotEmpty) {
      return "email-already-in-use";
    }
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final User? user = credential.user;

    // Send email verification
    if (user != null && !user.emailVerified) {
      print("Sending verification email");
      await user.sendEmailVerification();
    }

    // Set a timeout of 3 minutes (180 seconds) for email verification
    bool isEmailVerified = false;
    final timeoutDuration = Duration(minutes: 3);
    final endTime = DateTime.now().add(timeoutDuration);

    while (!isEmailVerified && DateTime.now().isBefore(endTime)) {
      if (cancel) {
        // If user cancels, delete account and exit
        print("Verification canceled. Deleting account.");
        await user!.delete();
        return "verification-canceled-deleted";
      }
      await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds
      await FirebaseAuth.instance.currentUser
          ?.reload(); // Reload the user from FirebaseAuth
      final updatedUser =
          FirebaseAuth.instance.currentUser; // Get the current user
      isEmailVerified =
          updatedUser?.emailVerified ?? false; // Check if verified
    }

    // If the email is verified within the timeout period
    if (isEmailVerified) {
      return user?.uid;
    } else {
      // If email is not verified within 3 minutes, delete the account
      final updatedUser = FirebaseAuth.instance.currentUser;
      if (updatedUser != null) {
        await updatedUser.reload(); // Ensure the user object is updated
        await updatedUser.delete(); // Delete the user if verification fails
      }
      return "email-not-verified-deleted";
    }
  } on FirebaseException catch (e) {
    if (e.code == 'email-already-in-use') {
      return "email-already-in-use";
    }
  } catch (e) {
    print(e);
  }
  return null;
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
  if (userInfo == null) {
    throw Exception("No user in database");
  }

  ElapseUser currentUser = ElapseUser(
      uid: user.uid,
      email: userInfo["email"],
      fname: userInfo["firstName"],
      lname: userInfo["lastName"],
      teamNumber: userInfo["team"]);

  prefs.setString("currentUser", jsonEncode(currentUser.toJson()));
  prefs.setString("teamGroup", userInfo["groupId"][0]);
  prefs.setString("savedTeam", jsonEncode(userInfo["savedTeam"]));
}
