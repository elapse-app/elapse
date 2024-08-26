import 'package:dots_indicator/dots_indicator.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:elapse_app/setup/signup/login_or_signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/deprecated/team_setup.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/setup/features/features_one.dart';
import 'package:elapse_app/setup/features/features_three.dart';

class FourthFeature extends StatelessWidget {
  const FourthFeature({super.key, });
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
                MaterialPageRoute(builder: (context) => ThirdFeature()),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 8),
                Text('Welcome',
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
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
        children: [
          SizedBox(height: 46),
          const Text(
            'Dive deeper',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 12, 77, 86),
            ),
          ),
          SizedBox(height: 2),
          const Text(
            'Get stats about your team',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 117, 117, 117),
            ),
          ),
          Spacer(flex: 1),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.50, // Fixed height
              width: MediaQuery.of(context).size.height * 0.50 / (452 / 240), // Fixed width (9:18 aspect ratio)
              child: Container(
                alignment: Alignment.center,
                child: Image.asset('assets/onboardingMyTeam.png'),
              ),
            ),
          ),
          Spacer(flex: 1),
          DotsIndicator(
            dotsCount: 4,
            position: 3,
            mainAxisSize: MainAxisSize.min,
            decorator: DotsDecorator(
              color: Color.fromARGB(255, 224, 224, 224), // Inactive color
              size: const Size.fromRadius(3.0),
              activeSize: const Size.fromRadius(3.0),
              activeColor: const Color.fromARGB(255, 148, 151, 151),
            ),
          ),
          Spacer(flex: 1),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(23.0, 0, 23.0, 23.0),
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
                        builder: (context) => SignUpPage(
                        ),
                      ),
                    );
                  },
                  child: Text('Next'),
                ),
              ),
            ),
          ),
          SizedBox(
            height:12,
          ),
        ],
      ),
      ),
    );
  }
}
