import 'package:elapse_app/extras/auth.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/complete_setup.dart';
import 'package:flutter/material.dart';
import '../../screens/widgets/app_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
                'Sign in',
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 46),
                    Center(
                      child: Text(
                        'Log into an account',
                        style: TextStyle(
                          fontFamily: "Manrope",
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 32),
                    Padding(
                      padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2.0,
                            ),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                              width: 2.0,
                            ),
                          ),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 38),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: LongButton(
                        text: "Login",
                        icon: Icons.mail_outline,
                        onPressed: () async {
                          await signIN(_emailController.text, _passwordController.text).then((a) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CompleteSetupPage(),
                                ));
                          }).catchError((onError) {
                            print(onError);
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text("Error Occured"),
                                    content: Text("An error occured when logging into your account, please try again"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                          ))
                                    ],
                                  );
                                });
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ]));
  }
}
