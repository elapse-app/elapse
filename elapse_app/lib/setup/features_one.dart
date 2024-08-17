import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/first_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/team_setup.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/main.dart';

class FirstFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
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
            'At a glance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          const Text(
            'Upcoming matches & info',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Center(
            child: Container(
              height: 450, // Fixed height
              width: 225, // Fixed width (9:18 aspect ratio)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey,
              ),
              child: Image.asset('assets/OnboardingHome.png'),
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
                    builder: (context) => FirstFeature(

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
