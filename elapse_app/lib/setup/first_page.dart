import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/theme_setup.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/features_one.dart'; 

class FirstSetupPage extends StatefulWidget {
  const FirstSetupPage({super.key});

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
          body: Column(
            children: [
              // Blue top section
              Container(
                height: MediaQuery.of(context).size.height * 0.64,
                color: Colors.blue,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Your new tournament companion. ',
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromARGB(255, 67, 129, 192),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Matches, Rankings, Scouting.',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontFamily: "Manrope",
                            fontSize: 24,
                            color: Colors.grey[350],
                          ),
                        ),
                        TextSpan(
                          text: '\n All in one place.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: "Manrope",
                            fontSize: 24,
                            color: const Color.fromARGB(255, 67, 129, 192),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 0), // Replace Spacer() with SizedBox for debugging
              // White bottom section with Get Started button
              Container(
                height: MediaQuery.of(context).size.height * 0.36 - 20,
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
                        child: Builder(
                          builder: (BuildContext context) {
                            return ElevatedButton(
                              onPressed: () {
                                print('Get Started button pressed');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FirstFeature(),
                                  ),
                                );
                              },
                              child: Text('Get Started'),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Builder(
                        builder: (BuildContext context) {
                          return TextButton(
                            onPressed: () {
                              print('Sign in button pressed');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FirstFeature(),
                                ),
                              );
                            },
                            child: RichText(
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
                            ),
                          );
                        },
                      ),
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