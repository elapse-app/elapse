import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/signup/login_or_signup.dart';
import 'package:elapse_app/setup/signup/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/welcome/features.dart';

// class FirstSetupPage extends StatefulWidget {
//   const FirstSetupPage({super.key});
//
//   @override
//   State<FirstSetupPage> createState() => _FirstSetupPageState();
// }
//
// class _FirstSetupPageState extends State<FirstSetupPage> {
class FirstSetupPage extends StatelessWidget {
  const FirstSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = false;
    if (Theme.of(context).brightness == Brightness.dark) {
      isDarkMode = true;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        bottom: false,
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(23.0, 23, 23.0, 0),
              child: SizedBox(
                width: 88,
                height: 32.5,
                child: Image.asset(isDarkMode ? 'assets/dg4x.png' : 'assets/lg4x.png'),
              ),
            ),
            Flexible(
              child: Container(),
              flex: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(23.0, 23, 23.0, 0),
              child: RichText(
                text: TextSpan(
                  text: 'Your new tournament companion. ',
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.w300,
                    fontFamily: "Manrope",
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Matches, Rankings, Scouting.',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 33,
                        fontFamily: "Manrope",
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(
                      text: '\n',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: '\nAll in one place.',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 33,
                        fontFamily: "Manrope",
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Container(),
              flex: 2,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(23.0, 23, 0, 9),
                        child: RichText(
                          textAlign: TextAlign.right,
                          text: TextSpan(
                            text: 'Welcome to Elapse',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Manrope",
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(23.0, 0, 23.0, 0),
                        child: RichText(
                          text: TextSpan(
                            text: 'The smart VRC App.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Manrope",
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 36.0,
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(23.0, 0.0, 23.0, 0),
                      child: LongButton(
                        gradient: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Features(),
                            ),
                          );
                        },
                        text: "Get Started",
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(23.0, 15.0, 23.0, 0),
                    child: LongButton(
                        isGray: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        text: "Existing User? Sign in"),
                  ),
                  SizedBox(
                    height: 23.0,
                  ),
                ],
              ),
            ),
          ],
        ),
        // child: Column(
        //   children: [
        //     // Blue top section
        //     Container(
        //       color: Theme.of(context).colorScheme.primary,
        //       child: Padding(
        //         padding: const EdgeInsets.fromLTRB(23.0, 23, 23.0, 0),
        //         child: Column(
        //           children: [
        //             Align(
        //               alignment: Alignment.centerLeft,
        //               child: SizedBox(
        //                 width: 88,
        //                 height: 32.5,
        //                 child: Image.asset(
        //                     isDarkMode ? 'assets/dg4x.png' : 'assets/lg4x.png'),
        //               ),
        //             ),
        //             SizedBox(
        //               height: MediaQuery.of(context).size.height * 0.13,
        //             ),
        //             Center(
        //               child: RichText(
        //                 text: TextSpan(
        //                   text: 'Your new tournament companion. ',
        //                   style: TextStyle(
        //                     fontSize: 33,
        //                     fontWeight: FontWeight.w300,
        //                     fontFamily: "Manrope",
        //                     color: Theme.of(context).colorScheme.secondary,
        //                   ),
        //                   children: <TextSpan>[
        //                     TextSpan(
        //                       text: 'Matches, Rankings, Scouting.',
        //                       style: TextStyle(
        //                         fontWeight: FontWeight.w300,
        //                         fontSize: 33,
        //                         fontFamily: "Manrope",
        //                         color: Theme.of(context).colorScheme.onSurface,
        //                       ),
        //                     ),
        //                     const TextSpan(
        //                       text: '\n',
        //                       style: TextStyle(
        //                         fontSize: 12,
        //                       ),
        //                     ),
        //                     TextSpan(
        //                       text: '\nAll in one place.',
        //                       style: TextStyle(
        //                         fontWeight: FontWeight.w500,
        //                         fontSize: 33,
        //                         fontFamily: "Manrope",
        //                         color: Theme.of(context).colorScheme.secondary,
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     Spacer(),
        //     Container(
        //       height: 300,
        //       decoration: BoxDecoration(
        //         color: Theme.of(context).colorScheme.surface,
        //         borderRadius: const BorderRadius.only(
        //           topLeft: Radius.circular(30),
        //           topRight: Radius.circular(30),
        //         ),
        //       ),
        //       child: Column(
        //         mainAxisAlignment: MainAxisAlignment.end,
        //         children: [
        //           Align(
        //             alignment: Alignment.centerLeft,
        //             child: Container(
        //               child: Padding(
        //                 padding: const EdgeInsets.all(23.0),
        //                 child: RichText(
        //                   textAlign: TextAlign.right,
        //                   text: TextSpan(
        //                     text: 'Welcome to Elapse',
        //                     style: TextStyle(
        //                       fontSize: 24,
        //                       fontWeight: FontWeight.w400,
        //                       fontFamily: "Manrope",
        //                       color: Theme.of(context).colorScheme.secondary,
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           Align(
        //             alignment: Alignment.centerLeft,
        //             child: Container(
        //               child: Padding(
        //                 padding: const EdgeInsets.fromLTRB(23.0, 0, 23.0, 0),
        //                 child: RichText(
        //                   text: TextSpan(
        //                     text: 'The smart VRC App.',
        //                     style: TextStyle(
        //                       fontSize: 16,
        //                       fontWeight: FontWeight.w400,
        //                       fontFamily: "Manrope",
        //                       color: Theme.of(context).colorScheme.onSurface,
        //                     ),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           Spacer(),
        //           Padding(
        //               padding: const EdgeInsets.fromLTRB(23.0, 0.0, 23.0, 0),
        //               child: LongButton(
        //                 gradient: true,
        //                 onPressed: () {
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) => const Features(),
        //                     ),
        //                   );
        //                 },
        //                 text: "Get Started",
        //               )),
        //           Padding(
        //             padding: const EdgeInsets.fromLTRB(23.0, 15.0, 23.0, 0),
        //             child: LongButton(
        //                 isGray: true,
        //                 onPressed: () {
        //                   Navigator.push(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) => const LoginPage(),
        //                     ),
        //                   );
        //                 },
        //                 text: "Existing User? Sign in"),
        //           ),
        //           SizedBox(
        //             height: 23.0,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
