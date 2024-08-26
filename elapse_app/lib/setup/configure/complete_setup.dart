import 'package:elapse_app/setup/configure/cloudscout_setup.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/screens/home/home.dart';

class CompleteSetupPage extends StatefulWidget {
  const CompleteSetupPage({super.key, });
  
  final int teamID = 0;
  //change later

  @override
  State<CompleteSetupPage> createState() => _CompleteSetupPageState();
}

class _CompleteSetupPageState extends State<CompleteSetupPage> {
  _CompleteSetupPageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 191, 231, 237),
      appBar: PreferredSize(
        preferredSize: MediaQuery.of(context).size * 0.07,
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 191, 231, 237),
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CloudScoutSetupPage()),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text('Complete',
                  style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
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
              Spacer(flex: 1),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.50, // Fixed height
                  width: MediaQuery.of(context).size.height * 0.50 / (452 / 240), // Fixed width (9:18 aspect ratio)
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset('assets/allDone.png'),
                  ),
                ),
              ),
              Spacer(flex: 2),
              SizedBox(
                        height: 59.0,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                          border: const GradientBoxBorder(
                            gradient: LinearGradient(colors: [Color.fromARGB(255, 191, 231, 237), Color.fromARGB(255, 221, 245, 255)]),
                            width: 1,
                          ),
                          gradient: RadialGradient(
                              colors: [ Color.fromARGB(25, 221, 245, 255), Color.fromARGB(50, 191, 231, 237),],
                              center: Alignment.center,
                              radius: 3,
                              stops: [0.0, 1.0],
                            ),
                          borderRadius: BorderRadius.circular(30)
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 12, 77, 86),
                    backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
                    ),
                    ),
                          onPressed: () {
                            Navigator.pushReplacement( 
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                        teamID: widget.teamID, // Pass the necessary parameters
                      ),
                      ),
                    );

                          },
                          child: Builder(
                            builder: (BuildContext context) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
                                children: [
                                  SizedBox(width: 5), 
                                  Image.asset('assets/darkIcon.png'), // Prefix icon
                                  SizedBox(width: 10), // Space between icon and text
                                  Text('Take me to the app'),
                                  Spacer(), // Pushes the suffix icon to the end
                                  Icon(Icons.arrow_forward, color: Color.fromARGB(255, 12, 77, 86)), // Suffix icon
                                  SizedBox(width: 5), 
                                ],
                              );
                            },
                          ),
                        ),
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