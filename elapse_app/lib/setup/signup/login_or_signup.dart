import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/setup/welcome/first_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/setup/signup/create_account.dart';

import '../../screens/widgets/app_bar.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({
    super.key,
  });

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
      //           Text('Sign up',
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
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 46),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Create an account',
                              style: TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: const Color.fromARGB(255, 12, 77, 86),
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 20),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                        child: Center(
                            child: RichText(
                                text: TextSpan(
                                  text: 'An Elapse account gives you',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Manrope",
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 117, 117, 117),
                                  ),
                                )))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                        child: Center(
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ' access to ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Manrope",
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 117, 117, 117),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'CloudScout ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Manrope",
                                      fontSize: 16,
                                      color: const Color.fromARGB(255, 12, 77, 86),
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'and more',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Manrope",
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 117, 117, 117),
                                    ),
                                  ),
                                ],
                              ),
                            ))),

                    //buttons for user
                    SizedBox(height: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 23.0,
                            vertical: 6.0,
                          ),
                          child: SizedBox(
                            height: 59.0,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 12, 77, 86),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  foregroundColor:
                                  const Color.fromARGB(255, 12, 77, 86),
                                  backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                                  side: BorderSide(
                                    color: const Color.fromARGB(255, 191, 231, 237),
                                    width: 1.0,
                                  )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreateAccount(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Aligns the content to the left
                                    children: [
                                      const Icon(Icons.mail_outline, size: 20), // Prefix Icon
                                      const SizedBox(
                                          width: 10), // Space between icon and text
                                      const Text('Sign up with email'),
                                      const Spacer(), // Pushes the suffix icon to the end
                                      Icon(Icons.arrow_forward,
                                          color: Theme.of(context).colorScheme.secondary), // Suffix icon
                                    ],
                                  ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            height: 18.0,
                            width: double.infinity,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Or choose to',
                                style: TextStyle(
                                  fontFamily: "Manrope",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 23.0,
                            vertical: 6.0,
                          ),
                          child: SizedBox(
                            height: 59.0,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).colorScheme.secondary,
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  foregroundColor: Theme.of(context).colorScheme.secondary,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  side: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 1.0,
                                  )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EnterDetailsPage(),
                                  ),
                                );
                              },
                              child: Builder(
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Aligns the content to the left
                                    children: [
                                      Image.asset('assets/google.png', height: 20, width: 20), // Prefix icon
                                      const SizedBox(
                                          width: 10), // Space between icon and text
                                      const Text('Sign up with Google'),
                                      const Spacer(), // Pushes the suffix icon to the end
                                      Icon(Icons.arrow_forward,
                                          color: Theme.of(context).colorScheme.secondary), // Suffix icon
                                    ],
                                  ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 23.0,
                            vertical: 6.0,
                          ),
                          child: SizedBox(
                            height: 59.0,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 12, 77, 86),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  foregroundColor:
                                  const Color.fromARGB(255, 12, 77, 86),
                                  backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                                  side: BorderSide(
                                    color: const Color.fromARGB(255, 191, 231, 237),
                                    width: 1.0,
                                  )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EnterDetailsPage(),
                                  ),
                                );
                              },
                              child: Builder(
                                builder: (BuildContext context) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Aligns the content to the left
                                    children: [
                                      SizedBox(width: 5),
                                      Container(
                                        height: 20,
                                        width: 20,
                                        child: Image.asset('assets/apple.png'),
                                      ), // // Prefix icon
                                      SizedBox(
                                          width: 10), // Space between icon and text
                                      Text('Sign up with Apple'),
                                      Spacer(), // Pushes the suffix icon to the end
                                      Icon(Icons.arrow_forward,
                                          color: Color.fromARGB(
                                              255, 12, 77, 86)), // Suffix icon
                                      SizedBox(width: 5),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 23.0,
                            vertical: 6.0,
                          ),
                          child: SizedBox(
                            height: 59.0,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                  const Color.fromARGB(255, 117, 117, 117),
                                  backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 148, 151, 151),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  side: BorderSide(
                                    color: const Color.fromARGB(255, 241, 241, 241),
                                    width: 1.0,
                                  )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FirstSetupPage(),
                                  ),
                                );
                              },
                              child: Builder(
                                builder: (BuildContext context) {
                                  return Text('Existing user? Sign in here');
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 23.0,
                            vertical: 6.0,
                          ),
                          child: SizedBox(
                            height: 59.0,
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                  const Color.fromARGB(255, 148, 151, 151),
                                  backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 255),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 241, 241, 241),
                                    fontFamily: "Manrope",
                                    fontWeight: FontWeight.w400,
                                  ),
                                  side: BorderSide(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    width: 1.0,
                                  )),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FirstSetupPage(),
                                  ),
                                );
                              },
                              child: Builder(
                                builder: (BuildContext context) {
                                  return Text('Use elapse without an account');
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 38),
                      ],
                    ),
                  ])),),
        ]
      )
    );
  }
}
