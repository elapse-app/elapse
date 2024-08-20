import 'package:dots_indicator/dots_indicator.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/features/first_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/deprecated/team_setup.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/setup/features/features_two.dart';


class FirstFeature extends StatelessWidget {
  const FirstFeature({super.key, required this.prefs});
  final SharedPreferences prefs;
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
                MaterialPageRoute(builder: (context) => FirstSetupPage(prefs: prefs)),
              );
            },
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => FirstSetupPage(prefs: prefs)),
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
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
        children: [
          SizedBox(height: 46),
          const Text(
            'At a glance',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Color.fromARGB(255, 12, 77, 86),
            ),
          ),
          SizedBox(height: 2),
          const Text(
            'Upcoming matches & info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 117, 117, 117),
            ),
          ),
          SizedBox(height: 30),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5, // Fixed height
              width: MediaQuery.of(context).size.height * 0.25, // Fixed width (9:18 aspect ratio)
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
            height:23.0,
          ),
          DotsIndicator(
            dotsCount: 4,
            position: 0,
            mainAxisSize: MainAxisSize.min,
            decorator: DotsDecorator(
              color: Color.fromARGB(255, 224, 224, 224), // Inactive color
              size: const Size.fromRadius(3.0),
              activeSize: const Size.fromRadius(3.0),
              activeColor: const Color.fromARGB(255, 148, 151, 151),
            ),
          ),
          Spacer(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(23.0),
              child: SizedBox(
                height: 59.0,
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color.fromARGB(255, 76, 81, 175),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 76, 81, 175),
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
                        builder: (context) => SecondFeature(
                          prefs: prefs
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
