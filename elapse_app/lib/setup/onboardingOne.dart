import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/theme_setup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Blue top section
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            color: Colors.blue,
            child: Center(
              child: Text(
                'Welcome',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Spacer(),
          // White bottom section with Get Started button
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      child: Text('Get Started'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}