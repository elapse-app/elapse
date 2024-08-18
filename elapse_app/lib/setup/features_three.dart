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
import 'package:elapse_app/setup/features_four.dart';

class ThirdFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Check rankings',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          const Text(
            'Find teams and stats',
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
                child: Image.asset('assets/onboardingRankings.png'),
              ),
            ),
          ),
         Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 55.0,
            width: double.infinity,
            child: ElevatedButton(
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
                    builder: (context) => FourthFeature(

                    ),
                  ),
                );
              },
              child: Text('Get Started'),
            ),
          ),
        ),
        ],
      ),
    );
  }
}
