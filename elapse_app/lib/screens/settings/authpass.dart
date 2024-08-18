import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPass extends StatefulWidget {
  const AuthPass({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<AuthPass> createState() => _AuthPassState();
}

class _AuthPassState extends State<AuthPass> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPassController0 = TextEditingController();
  TextEditingController newPassController1 = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
     body: Padding(
      padding: EdgeInsets.only(left: 20, right: 12, bottom: 20),
      child: Center(
        child: Form(
          child: Column(
            children: [
              IconButton(
                padding: EdgeInsets.only(right: 10, bottom: 10, top: 10),
                onPressed: () {
                  Navigator.pop(context);
                },
                highlightColor: Colors.transparent,
                icon: Icon(Icons.arrow_back, size: 24)),
              TextFormField(
                controller: newPassController0,
                decoration: const InputDecoration(
                  hintText: 'Enter New Password',
                ),
              ),
              TextFormField(
                controller: newPassController1,
                decoration: const InputDecoration(
                  hintText: 'Retype New Password',
                ),
              ),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  hintText: 'Enter Old Password',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  updatePass();
                },
                child: const Text('Update Password')
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> updatePass() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'unknown-error') {
        print('authErr - unknown-error / invalid pass');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Make sure you input a valid email and password!'),),
        );
        return;
      } else if (e.code == 'missing-email') {
        print('authErr - missing-email');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Make sure you input a valid email and password!'),),
        );
        return;
      } else if (e.code == 'invalid-email') {
        print('authErr - invalid-email');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Invalid email. Make sure you entered a real email!'),),
        );
        return;
      } else if (e.code == 'user-not-found') {
        print('authErr - user-not-found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Invalid email / password.'),),
        );
        return;
      } else if (e.code == 'wrong-password') {
        print('authErr - wrong-password');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Invalid email / password.'),),
        );
        return;
      } 
    } catch (e) {
      print(e);
    }
    if (newPassController0.text == newPassController1.text) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
      final user = credential.user;
      print('authSucc - signed in user with uuid: ${user?.uid}');
      await user?.updatePassword(newPassController1.text);
      print('authSucc - updated password');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Success! Your password has been updated. Please sign in again.'),),
      );
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } else {
      print('authErr - pass mismatch');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Passwords do not match. Are you sure you typed them correctly?'),),
      );
    }
  }
}