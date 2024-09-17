import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class CompleteSetupPage extends StatefulWidget {
  const CompleteSetupPage({
    super.key,
  });

  final int teamID = 0;
  //change later

  @override
  State<CompleteSetupPage> createState() => _CompleteSetupPageState();
}

class _CompleteSetupPageState extends State<CompleteSetupPage> {
  _CompleteSetupPageState();

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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 46,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'You\'re ready to go',
                                  style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
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
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'All set up!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Manrope",
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(flex: 1),
                          Center(
                            child: Container(
                              height: MediaQuery.of(context).size.height *
                                  0.50, // Fixed height
                              width: MediaQuery.of(context).size.height *
                                  0.50 /
                                  (452 /
                                      240), // Fixed width (9:18 aspect ratio)
                              child: Container(
                                alignment: Alignment.center,
                                child: Image.asset(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? 'assets/allDoneDark.png'
                                        : 'assets/allDone.png'),
                              ),
                            ),
                          ),
                          Spacer(flex: 2),
                          LongButton(
                              icon: Icons.send_rounded,
                              gradient: true,
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyApp(
                                          prefs: prefs), // Navigate to main app
                                    ),
                                    ModalRoute.withName("/Home"));
                              },
                              text: "Take me to the app"),
                          SizedBox(
                            height: 38,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]));
  }
}
