import 'package:dots_indicator/dots_indicator.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
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
      backgroundColor: Theme.of(context).colorScheme.primary,
      // appBar: PreferredSize(
      //   preferredSize: MediaQuery.of(context).size * 0.07,
      //   child: AppBar(
      //     automaticallyImplyLeading: false,
      //     backgroundColor: Theme.of(context).colorScheme.primary,
      //     title: GestureDetector(
      //       onTap: () {
      //         Navigator.pop(context);
      //       },
      //       child: const Row(
      //         children: [
      //           Icon(Icons.arrow_back),
      //           SizedBox(width: 12),
      //           Text('Create account',
      //             style: TextStyle(
      //           fontSize: 24,
      //           fontFamily: 'Manrope',
      //           fontWeight: FontWeight.w600,
      //           color: Color.fromARGB(255, 0, 0, 0),
      //         ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          ElapseAppBar(
            title: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 12),
                      Text('Sign up',
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ]
                ),
            maxHeight: 60,
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Container(
        height: double.infinity,
        width: double.infinity,
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
                child: Text(
                  'Get a streamlined view of matches, rankings, and more',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: "Manrope",
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
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
              Text(
                'Tournament mode enables the Events tab, where you can find matches and live stats.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Tournament mode can be activated the day of the event, and will be automatically deactivated afterwards.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Manrope",
                ),                
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 28,
              ),
              Text(
                'Live Timing helps you stay in sync',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: "Manrope",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Live timing detects if matches are delayed or early and updates the in app schedule automatically.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
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
      ),
      ),
        ]
      )
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
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    textStyle: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: "Manrope",
                      fontWeight: FontWeight.w400,
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
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
                fontFamily: "Manrope",
                fontSize: 16,
              ),
            ),
            Spacer(),
            Icon(_isEnabled ? Icons.toggle_on_outlined : Icons.toggle_off_outlined, 
            color: _isEnabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary, 
            size: 42),
          ],
        ),
      ),
    );
  }
}