import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthDel extends StatefulWidget {
  const AuthDel({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<AuthDel> createState() => _AuthDelState();
}

class _AuthDelState extends State<AuthDel> {
  TextEditingController emailController1 = TextEditingController();
  TextEditingController emailController2 = TextEditingController();
  TextEditingController passwordController0 = TextEditingController();
  TextEditingController passwordController1 = TextEditingController();

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
                controller: emailController1,
                decoration: const InputDecoration(
                  hintText: 'Email',
                ),
              ),
              TextFormField(
                controller: emailController2,
                decoration: const InputDecoration(
                  hintText: 'Retype Email',
                ),
              ),
              TextFormField(
                controller: passwordController0,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
              TextFormField(
                controller: passwordController1,
                decoration: const InputDecoration(
                  hintText: 'Retype Password',
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
        email: emailController2.text,
        password: passwordController1.text,
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
    if (emailController1.text == emailController2.text && passwordController0.text == passwordController1.text) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController2.text,
          password: passwordController1.text,
        );
      final user = credential.user;
      print('authSucc - signed in user with uuid: ${user?.uid}');
      await user?.delete();
      print('authSucc - deleted account');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Success! Your account has been deleted.'),),
      );
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } else {
      print('authErr - user/pass mismatch');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Emails or passwords do not match. Are you sure you typed them correctly?'),),
      );
    }
  }
}