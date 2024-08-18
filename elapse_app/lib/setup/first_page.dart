import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/theme_setup.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/features_one.dart'; 

class FirstSetupPage extends StatefulWidget {
  const FirstSetupPage({Key? key}) : super(key: key);

  @override
  State<FirstSetupPage> createState() => _FirstSetupPageState();
}

class _FirstSetupPageState extends State<FirstSetupPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Colors.blue,
          body: Column(
            children: [
              // Blue top section
              Container(
                height: MediaQuery.of(context).size.height * 0.64,
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Your new tournament companion. ',
                        style: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: 32,
                          fontWeight: FontWeight.normal,
                          color: const Color.fromARGB(255, 67, 129, 192),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Matches, Rankings, Scouting.',
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontFamily: "Manrope",
                              fontSize: 32,
                              color: Colors.grey[350],
                            ),
                          ),
                          TextSpan(
                            text: '\nAll in one place.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "Manrope",
                              fontSize: 32,
                              color: const Color.fromARGB(255, 67, 129, 192),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ),
              SizedBox(height: 0), // Replace Spacer() with SizedBox for debugging
              // White bottom section with Get Started button
              Container(
                height: MediaQuery.of(context).size.height * 0.36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                              )
                            ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FirstFeature(),
                              ),
                            );
                          },
                          child: Builder(
                            builder: (BuildContext context) {
                              return Text('Get Started');
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                          height: 55,
                          width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color.fromARGB(255, 76, 81, 175),
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            side: BorderSide(
                              color: const Color.fromARGB(255, 76, 81, 175),
                              width: 2.0,
                              )
                            ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FirstFeature(),
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
                                    fontSize: 16,
                                    color: Colors.grey[350],
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' Sign in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Colors.grey[350],
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
                      height:16,
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