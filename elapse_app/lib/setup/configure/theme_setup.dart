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
                    height: 46,
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
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 12, 77, 86),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Choose a theme you want to use',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
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
                              colorProvider.setSystem();
                              setState(() {
                                theme = "system";
                              });
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
                                children: [
                                  SizedBox(width: 5), 
                                  Image.asset((theme == "system" ? 'assets/radio_button_checked.png': 'assets/radio_button_unchecked.png')), // Prefix icon
                                  SizedBox(width: 10), // Space between icon and text
                                  Text('Follow System', 
                                    style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 12, 77, 86),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),), 
                                  Spacer(), // Pushes the suffix icon to the end
                                  Image.asset('assets/system.png'), // Suffix icon
                                  SizedBox(width: 5), 
                                ],
                              ),
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
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
                              colorProvider.setLight();
                              setState(() {
                                theme = "light";
                              });
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
                                children: [
                                  SizedBox(width: 5), 
                                  Image.asset((theme == "light" ? 'assets/radio_button_checked.png': 'assets/radio_button_unchecked.png')), // Prefix icon
                                  SizedBox(width: 10), // Space between icon and text
                                  Text('Light', 
                                    style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 12, 77, 86),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),), 
                                  Spacer(), // Pushes the suffix icon to the end
                                  Image.asset('assets/lightMode.png'), // Suffix icon
                                  SizedBox(width: 5), 
                                ],
                              ),
                          ),
                        ),
                        SizedBox(height: 12),
                        SizedBox(
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
                              colorProvider.setDark();
                              setState(() {
                                theme = "dark";
                              });
                            },
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
                                children: [
                                  SizedBox(width: 5), 
                                  Image.asset((theme == "dark" ? 'assets/radio_button_checked.png': 'assets/radio_button_unchecked.png')), // Prefix icon
                                  SizedBox(width: 10), // Space between icon and text
                                  Text('Dark', 
                                    style: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 12, 77, 86),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),), 
                                  Spacer(), // Pushes the suffix icon to the end
                                  Image.asset('assets/darkMode.png'), // Suffix icon
                                  SizedBox(width: 5), 
                                ],
                              ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(
                    height: 32,
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: SizedBox(
                      height: 59.0,
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
                  SizedBox(
                height:12,
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