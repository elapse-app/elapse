import 'package:elapse_app/setup/configure/complete_setup.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/configure/tournament_mode_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudScoutSetupPage extends StatefulWidget {
  const CloudScoutSetupPage({super.key, });

  @override
  State<CloudScoutSetupPage> createState() => _CloudScoutSetupPageState();
}

class _CloudScoutSetupPageState extends State<CloudScoutSetupPage> {
  _CloudScoutSetupPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 191, 231, 237),
      appBar: PreferredSize(
        preferredSize: MediaQuery.of(context).size * 0.07,
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 191, 231, 237),
          title: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 12),
                Text('CloudScout',
                  style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
                ),
              ],
            ),
          ),
        ),
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
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1, // Fixed height
                  width: MediaQuery.of(context).size.height * 0.1 * 306 / 90, // Fixed width (9:18 aspect ratio)
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset('assets/cloudScout.png'),
                  ),
                ),
              ),
              SizedBox(height: 24),
              const Text(
                'CloudScout allows you to sync scouting data with other devices and share seamlessly with your teammates and coaches.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Manrope",
                  color: Color.fromARGB(255, 117, 117, 117),
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
                  color: Color.fromARGB(255, 117, 117, 117),
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ThemeSetup(
                    //       prefs: widget.prefs,
                    //     ),
                    //   ),
                    // );
                    Navigator.push( 
                      context,
                      MaterialPageRoute(
                        builder: (context) => CompleteSetupPage(
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