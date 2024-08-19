import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthEmail extends StatefulWidget {
  const AuthEmail({super.key});

  @override
  State<AuthEmail> createState() => _AuthEmailState();
}

class _AuthEmailState extends State<AuthEmail> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newEmailController0 = TextEditingController();
  TextEditingController newEmailController1 = TextEditingController();

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
                    controller: newEmailController0,
                    decoration: const InputDecoration(
                      hintText: 'Enter New Email',
                    ),
                  ),
                  TextFormField(
                    controller: newEmailController1,
                    decoration: const InputDecoration(
                      hintText: 'Enter New Email',
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter Old Email',
                    ),
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        updateEmail();
                      },
                      child: const Text('Update Email')),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> updateEmail() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'unknown-error') {
        print('authErr - unknown-error / invalid pass');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Make sure you input a valid email and password!'),
          ),
        );
        return;
      } else if (e.code == 'missing-email') {
        print('authErr - missing-email');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Make sure you input a valid email and password!'),
          ),
        );
        return;
      } else if (e.code == 'invalid-email') {
        print('authErr - invalid-email');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Invalid email. Make sure you entered a real email!'),
          ),
        );
        return;
      } else if (e.code == 'user-not-found') {
        print('authErr - user-not-found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email / password.'),
          ),
        );
        return;
      } else if (e.code == 'wrong-password') {
        print('authErr - wrong-password');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid email / password.'),
          ),
        );
        return;
      }
    } catch (e) {
      print(e);
    }
    if (newEmailController0.text == newEmailController1.text) {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      final user = credential.user;
      print('authSucc - signed in user with uuid: ${user?.uid}');
      await user?.verifyBeforeUpdateEmail(newEmailController1.text);
      print('authSucc - updated email');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Success! Check your email to verify this change, then sign in again.'),
        ),
      );
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
    } else {
      print('authErr - email mismatch');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Emails do not match. Are you sure you typed them correctly?'),
        ),
      );
    }
  }
}
