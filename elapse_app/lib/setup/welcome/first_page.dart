import 'package:elapse_app/setup/signup/login_or_signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/welcome/features.dart';
import 'package:gradient_borders/gradient_borders.dart'; 

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
    return Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        colorProvider.setSystem();
      });

      return Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.primary,
              body: Column(
                children: [
                  // Blue top section
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(23.0, 60.0, 23.0, 0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 88,
                              height: 32.5,
                              child: Image.asset('assets/lg4x.png'),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.13,
                          ),
                          Center(
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
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(23.0),
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
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23.0, 0.0, 23.0, 0),
                          child: SizedBox(
                            height: 59.0,
                            width: double.infinity,
                            child: Container(
                              decoration: BoxDecoration(
                                border: const GradientBoxBorder(
                                  gradient: LinearGradient(colors: [Color.fromARGB(255, 191, 231, 237), Color.fromARGB(255, 221, 245, 255)]),
                                  width: 1,
                                ),
                                gradient: RadialGradient(
                                  colors: [Theme.of(context).colorScheme.primary.withOpacity(0.05), Theme.of(context).colorScheme.primary],
                                  center: Alignment.center,
                                  radius: 3,
                                  stops: const [0.0, 1.0],
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.secondary,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Features(),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 5),
                                    Image.asset('assets/darkIcon.png'),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "Manrope",
                                        color: Theme.of(context).colorScheme.secondary,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.secondary),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(23.0, 12, 23.0, 0),
                          child: SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                  width: 2.0,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Existing user?',
                                  style: TextStyle(
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w200,
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' Sign in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 23.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
