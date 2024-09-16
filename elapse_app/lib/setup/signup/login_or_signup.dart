import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/signup/login_page.dart';
import 'package:flutter/material.dart';
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
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 46),
                          Center(
                            child: Text(
                              'Create an account',
                              style: TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                              child: Center(
                                  child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'An Elapse account gives you',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' access to ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'CloudScout ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'and more',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Manrope",
                                        fontSize: 16,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
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
                                child: LongButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const CreateAccount(),
                                        ),
                                      );
                                    },
                                    icon: Icons.email_outlined,
                                    text: "Sign up with Email"),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                          Text(
                            "More sign up options coming soon",
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5)),
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 23.0,
                                    vertical: 6.0,
                                  ),
                                  child: LongButton(
                                    text: "Existing User? Sign in Here",
                                    useForwardArrow: false,
                                    centerAlign: true,
                                    isGray: true,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    },
                                  )),
                              const SizedBox(height: 64),
                            ],
                          ),
                        ])),
              ),
            ]));
  }
}
