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
                  if(emailController.text.isNotEmpty && passwordController.text.length > 6) {
                    login(); 
                  } else {
                    debugPrint('LOG: Email is empty or password is invalid');
                  }
                },
                child: const Text('Login')
              ),
              TextButton(
                onPressed: (){
                  final auth = FirebaseAuth.instance;
                  auth.createUserWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
                }, 
                child: Text('Sign Up')
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> login() async{
    final auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
  }
}