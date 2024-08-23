import 'package:elapse_app/setup/configure/cloudscout_setup.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/screens/home/home.dart';

class CompleteSetupPage extends StatefulWidget {
  const CompleteSetupPage({super.key, required this.prefs});
  final SharedPreferences prefs;
  
  final int teamID = 0;
  //change later

  @override
  State<CompleteSetupPage> createState() => _CompleteSetupPageState(prefs: prefs);
}

class _CompleteSetupPageState extends State<CompleteSetupPage> {
  _CompleteSetupPageState({required this.prefs});
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
              SizedBox(
                height:46,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'You\'re ready to go',
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
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'All set up!',
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
                  height: MediaQuery.of(context).size.height * 0.56, // Fixed height
                  width: MediaQuery.of(context).size.height * 0.28, // Fixed width (9:18 aspect ratio)
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    color: Colors.black,
                  ),
                  child: Container(
                alignment: Alignment.center,
                height: 480,
                width: 240,
                color: Colors.grey[200],
                child: Container(
                  alignment: Alignment.center,
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(65),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: 80,
                    width: 80,
                    child: Icon(
                      Icons.checklist,
                      color: Colors.white,
                      size: 40,
                    ),
                  )
                ),
              ),
                ),
              ),
              Spacer(),
              SizedBox(
                height: 59.0,
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
                        builder: (context) => HomeScreen(
                        teamID: widget.teamID, // Pass the necessary parameters
                      ),
                      ),
                    );
                  },
                  child: Text('Take me to the app'),
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