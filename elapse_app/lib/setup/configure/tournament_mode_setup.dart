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
import 'package:elapse_app/setup/features/features_one.dart';
import 'package:elapse_app/setup/features/features_three.dart';

class TournamentModeSetupPage extends StatelessWidget {
  const TournamentModeSetupPage({super.key, required this.prefs});
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Tournament Mode',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: const Text(
                  'Get a streamlined view of matches, rankings, and more',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              const Text(
                'Tournament mode enables the Events tab, where you can find matches and live stats.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              const Text(
                'Tournament mode can be activated the day of the event, and will be automatically deactivated afterwards.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 28,
              ),
              const Text(
                'Live Timing helps you stay in sync',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              const Text(
                'Live timing detects if matches are delayed or early and updates the in app schedule automatically.',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              ToggleableButton(),
              Spacer(),
              Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0),
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
                    builder: (context) => ThirdFeature(
                      prefs: prefs
                    ),
                  ),
                );
              },
              child: Text('Next'),
            ),
          ),
        ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToggleableButton extends StatefulWidget {
  @override
  _ToggleableButtonState createState() => _ToggleableButtonState();
}

class _ToggleableButtonState extends State<ToggleableButton> {
  bool _isEnabled = false;

  void _toggleButton() {
    setState(() {
      _isEnabled = !_isEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55.0,
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 76, 81, 175),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          side: BorderSide(
            color: const Color.fromARGB(255, 76, 81, 175),
            width: 2.0,
          ),
        ),
        onPressed: () {
          _toggleButton();
          
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ' Use Live Timing',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: "Manrope",
                fontSize: 19,
              ),
            ),
            Spacer(),
            Icon(
              _isEnabled ? Icons.check_circle : Icons.cancel,
              color: _isEnabled ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}