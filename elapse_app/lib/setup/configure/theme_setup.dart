import 'package:elapse_app/main.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/configure/tournament_mode_setup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSetup extends StatefulWidget {
  const ThemeSetup({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<ThemeSetup> createState() => _ThemeSetupState(prefs: prefs);
}

String theme = "system";

class _ThemeSetupState extends State<ThemeSetup> {
  _ThemeSetupState({required this.prefs});
  SharedPreferences prefs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Join Team'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Personalize Elapse',
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 32,
                        fontWeight: FontWeight.normal,
                        color: const Color.fromARGB(255, 67, 129, 192),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Choose a theme you want to use',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontFamily: "Manrope",
                        fontSize: 18,
                        color: Colors.grey[350],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
                  Consumer<ColorProvider>(builder: (
                    context,
                    colorProvider,
                    snapshot,
                  ) {
                    return Column(
                      children: [
                        SizedBox(
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
                              colorProvider.setSystem();
                              setState(() {
                                theme = "system";
                              });
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'System',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Manrope",
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.settings,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 5,
                                    backgroundColor: theme == "system"
                                        ? Theme.of(context).colorScheme.secondary
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
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
                              colorProvider.setLight();
                              setState(() {
                                theme = "light";
                              });
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'Light',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Manrope",
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.light_mode,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 5,
                                    backgroundColor: theme == "light"
                                        ? Theme.of(context).colorScheme.secondary
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        SizedBox(
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
                              colorProvider.setDark();
                              setState(() {
                                theme = "dark";
                              });
                            },
                            child: Stack(
                              children: [
                                Center(
                                  child: Text(
                                    'Dark',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Manrope",
                                      fontSize: 19,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.dark_mode,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                Positioned(
                                  left: 16,
                                  top: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 5,
                                    backgroundColor: theme == "dark"
                                        ? Theme.of(context).colorScheme.secondary
                                        : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(
                    height: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
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
                              builder: (context) => TournamentModeSetupPage(
                                prefs: prefs,
                              ),
                            ),
                          );
                        },
                        child: Text('Next'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}