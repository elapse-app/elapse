import 'package:elapse_app/setup/signup/login_or_signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/features/features_one.dart'; 

class FirstSetupPage extends StatefulWidget {
  const FirstSetupPage({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<FirstSetupPage> createState() => _FirstSetupPageState(prefs: prefs);
}

class _FirstSetupPageState extends State<FirstSetupPage> {
  _FirstSetupPageState({required this.prefs});
  final SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 191, 231, 237),
          body: Column(
            children: [
              // Blue top section
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
              ),
              Container(
                color: Color.fromARGB(255, 191, 231, 237),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Your new tournament companion. ',
                        style: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: 33,
                          fontWeight: FontWeight.w300,
                          color: const Color.fromARGB(255, 12, 77, 86),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Matches, Rankings, Scouting.',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontFamily: "Manrope",
                              fontSize: 33,
                              color: Color.fromARGB(255, 35, 35, 35),
                            ),
                          ),
                          TextSpan(
                            text: '\nAll in one place.',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: "Manrope",
                              fontSize: 33,
                              color: const Color.fromARGB(255, 22, 98, 128),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ),
              Spacer(),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(23.0),
                          child: RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              
                              text: 'Welcome to Elapse',
                              style: TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 12, 77, 86),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(23.0, 0, 23.0, 0),
                          child: RichText(
                            text: TextSpan(
                              text: 'The smart VRC App.',
                              style: TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23.0,0.0,23.0, 0),
                      child: SizedBox(
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
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FirstFeature(
                                  prefs: prefs,
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
                                  Text('Get Started'),
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(23.0,12,23.0,0),
                      child: SizedBox(
                          height: 55,
                          width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            side: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              width: 2.0,
                              )
                            ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(prefs: prefs),
                              ),
                            );
                          },
                          child: Builder(
                            builder: (BuildContext context) {
                              return RichText(
                                text: TextSpan(
                                  text: 'Existing user?',
                                  style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w200,
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 148, 151, 151),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' Sign in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Color.fromARGB(255, 117, 117, 117),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:23.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}