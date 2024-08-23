import 'package:elapse_app/setup/configure/complete_setup.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudScoutSetupPage extends StatefulWidget {
  const CloudScoutSetupPage({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<CloudScoutSetupPage> createState() => _CloudScoutSetupPageState(prefs: prefs);
}

class _CloudScoutSetupPageState extends State<CloudScoutSetupPage> {
  _CloudScoutSetupPageState({required this.prefs});
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Join Team'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: Column(
            children: [
              SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'You’ve got CloudScout',
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 12, 77, 86),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Thanks for signing in! Enjoy CloudScout Picklist, Scoutsheets, and Saved Teams',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: "Manrope",
                        fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
              ),
              SizedBox(height: 24),
              const Text(
                'CloudScout allows you to sync scouting data with other devices and share seamlessly with your teammates and coaches.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              const Text(
                'Try it out in the Scout tab',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              SizedBox(
                height: 55.0,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 12, 77, 86),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 191, 231, 237),
                      width: 1.0,
                      )
                    ),
                  onPressed: () {
                    // Navigate to the next page
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ThemeSetup(
                    //       prefs: widget.prefs,
                    //     ),
                    //   ),
                    // );
                    Navigator.pushReplacement( 
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompleteSetupPage(
                          prefs: prefs
                        ),
                      ),
                    );
                  },
                  child: Text('Next'),
                ),
              ),
              SizedBox(
                height:38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}