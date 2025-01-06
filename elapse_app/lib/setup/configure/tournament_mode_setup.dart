import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/cloudscout_setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'complete_setup.dart';

class TournamentModeSetupPage extends StatefulWidget {
  const TournamentModeSetupPage({
    super.key,
  });

  @override
  State<TournamentModeSetupPage> createState() => _TournamentModeSetupPageState();
}

class _TournamentModeSetupPageState extends State<TournamentModeSetupPage> {
  bool useLiveTiming = true;
  bool useMatchNotifs = false;

  @override
  void initState() {
    super.initState();
    prefs.setBool("useLiveTiming", useLiveTiming);
    super.initState();
    prefs.setBool("useMatchNotifs", useMatchNotifs);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: CustomScrollView(physics: const NeverScrollableScrollPhysics(), slivers: [
          ElapseAppBar(
            title: Row(children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 12),
              Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ]),
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
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 23, vertical: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 46),
                          Text(
                            'Tournament Mode',
                            style: TextStyle(
                              fontFamily: "Manrope",
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.secondary,
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
                              width: MediaQuery.of(context).size.height *
                                  0.1 *
                                  306 /
                                  99, // Fixed width (9:18 aspect ratio)
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
                      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 23.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Use Live Timing',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Manrope",
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Switch(
                            value: useLiveTiming,
                            onChanged: (value) {
                              prefs.setBool("useLiveTiming", value);
                              setState(() {
                                useLiveTiming = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: LongButton(
                          centerAlign: true,
                          useForwardArrow: false,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => prefs.getString("currentUser") != null &&
                                        FirebaseAuth.instance.currentUser!.emailVerified
                                    ? CloudScoutSetupPage()
                                    : CompleteSetupPage(),
                              ),
                            );
                          },
                          text: "Next"),
                    ),
                    SizedBox(
                      height: 38,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}
