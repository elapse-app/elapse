import 'package:elapse_app/setup/configure/join_team.dart';
import 'package:elapse_app/setup/configure/team_setup.dart';
import 'package:elapse_app/setup/signup/verify_account.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterDetailsPage extends StatelessWidget {
  const EnterDetailsPage({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _ageController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Enter your details',
                    style: TextStyle(
                      fontFamily: "Manrope",
                      fontSize: 30,
                      fontWeight: FontWeight.normal,
                      color: const Color.fromARGB(255, 67, 129, 192),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Please fill in the fields below',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontFamily: "Manrope",
                      fontSize: 19,
                      color: Colors.grey[350],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                  labelStyle: TextStyle(
                    color: Colors.grey[350],
                    fontWeight: FontWeight.normal,
                    fontFamily: "Manrope",
                    fontSize: 19,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Age',
                  labelStyle: TextStyle(
                    color: Colors.grey[350],
                    fontWeight: FontWeight.normal,
                    fontFamily: "Manrope",
                    fontSize: 19,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 55.0,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 76, 81, 175),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 76, 81, 175),
                      width: 2.0,
                    ),
                  ),
                  onPressed: () {
                    final name = _nameController.text;
                    final age = _ageController.text;
                    // Use the collected name and age here
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JoinTeamPage(prefs: prefs),
                      ),
                    );
                  },
                  child: Builder(
                    builder: (BuildContext context) {
                      return Text(
                        'Next',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontFamily: "Manrope",
                          fontSize: 19,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}