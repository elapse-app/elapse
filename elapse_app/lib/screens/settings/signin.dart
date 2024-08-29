import 'package:elapse_app/extras/database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthSignIn extends StatefulWidget {
  const AuthSignIn({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<AuthSignIn> createState() => _AuthSignInState();
}

class _AuthSignInState extends State<AuthSignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
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
                        signIN();
                      },
                      child: const Text('Sign In')),
                  ElevatedButton(
                      onPressed: () {
                        signUP();
                      },
                      child: Text('Sign Up')),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> signIN() async {
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
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    final User? user = credential.user;
    // Add to the Database
    await Database().createUser(user);
    print('authSucc - signed in user with uuid: ${user?.uid}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Success! You have been signed in.'),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> signUP() async {
    try {
      // Create user with email and password
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      final User? user = credential.user;

      // Send email verification
      if (user != null && !user.emailVerified) {
        print("Sending verification email");
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                const Text('Verification email sent. Please check your email.'),
          ),
        );
      }

      // Check for email verification in a loop
      bool isEmailVerified = false;
      while (!isEmailVerified) {
        await Future.delayed(Duration(seconds: 3)); // Wait for 3 seconds
        await FirebaseAuth.instance.currentUser
            ?.reload(); // Reload the user from FirebaseAuth instance
        final updatedUser =
            FirebaseAuth.instance.currentUser; // Get the current user
        isEmailVerified =
            updatedUser?.emailVerified ?? false; // Check if verified
        print('Email verified status: ${updatedUser?.emailVerified}');
      }

      print('authSucc - signed up and verified user with uuid: ${user?.uid}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Success! Your account has been verified and created.'),
        ),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      handleAuthError(e);
    } catch (e) {
      print(e);
    }
  }

  void handleAuthError(FirebaseAuthException e) {
    if (e.code == 'unknown-error') {
      showErrorSnackbar('Make sure you input a valid email and password!');
    } else if (e.code == 'missing-email') {
      showErrorSnackbar('Make sure you input a valid email and password!');
    } else if (e.code == 'invalid-email') {
      showErrorSnackbar('Invalid email. Make sure you entered a real email!');
    } else if (e.code == 'weak-password') {
      showErrorSnackbar(
          'The password provided is too weak. Ensure it is at least 6 characters!');
    } else if (e.code == 'email-already-in-use') {
      showErrorSnackbar('An account already exists for that email.');
    }
  }

  void showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
