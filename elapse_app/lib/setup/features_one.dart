import 'package:dots_indicator/dots_indicator.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/first_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/team_setup.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/setup/features_two.dart';

class FirstFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FirstSetupPage()),
              );
            },
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FirstSetupPage()),
              );
            },
            child: const Row(
              children: [
                SizedBox(width: 8),
                Text('Welcome'),
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
        children: [
          const Text(
            'At a glance',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          const Text(
            'Upcoming matches & info',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              height: 486, // Fixed height
              width: 246, // Fixed width (9:18 aspect ratio)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: Colors.black,
              ),
              child: Container(
                alignment: Alignment.center,
                height: 480,
                width: 240,
                child: Image.asset('assets/onboardingHome.png'),
              ),
            ),
          ),
          SizedBox(
            height:16,
          ),
          DotsIndicator(
            dotsCount: 4,
            position: 0,
            decorator: DotsDecorator(
              color: Colors.black87, // Inactive color
              activeColor: const Color.fromARGB(255, 151, 35, 35),
            ),
          ),
          Spacer(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
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
                        builder: (context) => SecondFeature(

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
            height:16,
          ),
        ],
      ),

      ),
    );
  }
}
