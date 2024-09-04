import 'package:dots_indicator/dots_indicator.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/configure/cloudscout_setup.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/welcome/first_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/deprecated/team_setup.dart';
import 'package:elapse_app/screens/home/home.dart';
import 'package:elapse_app/main.dart';

class TournamentModeSetupPage extends StatelessWidget {
  const TournamentModeSetupPage({super.key,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 191, 231, 237),
      appBar: PreferredSize(
        preferredSize: MediaQuery.of(context).size * 0.07,
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 191, 231, 237),
          title: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 12),
                Text('Info',
                  style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
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
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 23, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height:46),
              const Text(
                'Tournament Mode',
                style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 12, 77, 86),
                      ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: const Text(
                  'Get a streamlined view of matches, rankings, and more',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: "Manrope",
                    fontSize: 16,
                    color: Color.fromARGB(255, 35, 35, 35),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.1, // Fixed height
                  width: MediaQuery.of(context).size.height * 0.1 * 306 / 99, // Fixed width (9:18 aspect ratio)
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset('assets/tournamentMode.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              const Text(
                'Tournament mode enables the Events tab, where you can find matches and live stats.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              const Text(
                'Tournament mode can be activated the day of the event, and will be automatically deactivated afterwards.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontWeight: FontWeight.w400,
                  fontFamily: "Manrope",
                ),                
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 28,
              ),
              const Text(
                'Live Timing helps you stay in sync',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              const Text(
                'Live timing detects if matches are delayed or early and updates the in app schedule automatically.',
                style: TextStyle(
                  color: Color.fromARGB(255, 117, 117, 117),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 24,
              ),
            ],
            
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
              child: ToggleableButton(),
            ),
              Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 23.0),
          child: SizedBox(
            height: 55.0,
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
                Navigator.push( 
                  context,
                  MaterialPageRoute(
                    builder: (context) => CloudScoutSetupPage(
                      
                    ),
                  ),
                );
              },
              child: Text('Next'),
            ),
          ),
        ),
              SizedBox(
                height: 38,
              ),
              ],
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
                    foregroundColor: const Color.fromARGB(255, 12, 77, 86),
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      width: 1.0,
                      )
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
                color: Color.fromARGB(255, 35, 35, 35),
                fontWeight: FontWeight.w400,
                fontFamily: "Manrope",
                fontSize: 16,
              ),
            ),
            Spacer(),
            Image.asset(_isEnabled ? "assets/enabled.png" : "assets/disabled.png"),
            
          ],
        ),
      ),
    );
  }
}