import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class passScreen extends StatelessWidget {
  const passScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              'You\'re Signed In!',
              style: TextStyle(),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Text(
                'Logout',
                style: TextStyle(),
              ),
            ),
          ],
        )
      ),
    );
  }
}