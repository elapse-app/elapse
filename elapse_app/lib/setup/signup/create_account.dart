import 'package:elapse_app/extras/auth.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:elapse_app/setup/signup/verify_account.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';
import '../../screens/widgets/app_bar.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    super.key,
  });

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _verifyPassController.dispose();
    super.dispose();
  }

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
                onTap: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    await FirebaseAuth.instance.currentUser!.reload();
                    await FirebaseAuth.instance.currentUser!.delete();
                  }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 46),
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
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                      child: Center(
                        child: Text(
                          'You will receive an email to verify your account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Padding(
                      padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
<<<<<<< HEAD
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
=======
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
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
<<<<<<< HEAD
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
=======
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
                          helperText: "8+ Characters",
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                      child: TextFormField(
                        controller: _verifyPassController,
                        obscureText: true,
                        autofocus: false,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide(
<<<<<<< HEAD
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
=======
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
                          labelText: 'Confirm Password',
                          helperText: "Please re-enter your password",
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                            fontSize: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please re-enter your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Please make sure your passwords match';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 38),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: LongButton(
                        text: "Create Account",
                        icon: Icons.person_add_alt,
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState!.validate()) {
                            String? signUpState = await signUp(_emailController.text, _passwordController.text);

                            if (signUpState == "email-already-in-use") {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Email already in use"),
                                      content: Text("Login with this email, or create a new account"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Close",
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                            ))
                                      ],
                                    );
                                  });
                              return;
                            } else if (signUpState != "success") {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Error Occurred"),
                                      content: Text("An unexpected error occurred."),
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              final updatedUser = FirebaseAuth.instance.currentUser;
                                              if (updatedUser != null) {
                                                await updatedUser.reload(); // Ensure the user object is updated
                                                await updatedUser.delete(); // Delete the user if verification fails
                                              }
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Close",
                                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                            ))
                                      ],
                                    );
                                  });
                              return;
                            }

                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  bool verified = false;
                                  return AlertDialog(
                                    title: Text("Verify Email"),
                                    content: Text(
                                        "Would you like to verify your account now? You will need to verify for CloudScout"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const EnterDetailsPage(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            "Later",
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                          )),
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            bool initBuild = false;
                                            FirebaseAuth.instance.currentUser!.sendEmailVerification();
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return StatefulBuilder(builder: (context, setState) {
                                                    if (!initBuild) {
                                                      initBuild = true;
                                                      verify() async {
                                                        DateTime timeout = DateTime.now().add(Duration(minutes: 3));
                                                        while (!FirebaseAuth.instance.currentUser!.emailVerified &&
                                                            DateTime.now().isBefore(timeout)) {
                                                          await Future.delayed(Duration(seconds: 5));
                                                          await FirebaseAuth.instance.currentUser!.reload();
                                                        }

                                                        if (FirebaseAuth.instance.currentUser!.emailVerified) {
                                                          setState(() {
                                                            verified = true;
                                                          });
                                                        } else {
                                                          Navigator.pop(context);
                                                          final updatedUser = FirebaseAuth.instance.currentUser;
                                                          if (updatedUser != null) {
                                                            await updatedUser
                                                                .reload(); // Ensure the user object is updated
                                                            await updatedUser
                                                                .delete(); // Delete the user if verification fails
                                                          }

                                                          showDialog(
                                                              context: context,
                                                              builder: (context) {
                                                                return AlertDialog(
                                                                  title: Text("Verification Timed Out"),
                                                                  content: Text(
                                                                      "Elapse was unable to verify your email in time."),
                                                                  actions: [
                                                                    TextButton(
                                                                        onPressed: () async {
<<<<<<< HEAD
                                                                          await FirebaseAuth.instance.currentUser!.reload();
                                                                          await FirebaseAuth.instance.currentUser!.delete();
=======
                                                                          await FirebaseAuth.instance.currentUser!
                                                                              .reload();
                                                                          await FirebaseAuth.instance.currentUser!
                                                                              .delete();
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text(
                                                                          "Close",
                                                                          style: TextStyle(
                                                                              color: Theme.of(context)
                                                                                  .colorScheme
                                                                                  .secondary),
                                                                        )),
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      }

                                                      verify();
                                                    }

                                                    return AlertDialog(
                                                      title: Text("Verify Email"),
                                                      content: Text.rich(
                                                        TextSpan(
                                                            text:
                                                                "Check your email for a verification link. You have 3 minutes to verify. Afterwards, click the ",
                                                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                                                            children: [
                                                              TextSpan(
                                                                text: "continue",
                                                                style: TextStyle(
                                                                    fontSize: 14, fontWeight: FontWeight.w500),
                                                              ),
                                                              TextSpan(
                                                                text: " button below.",
                                                                style: TextStyle(
                                                                    fontSize: 14, fontWeight: FontWeight.w300),
                                                              )
                                                            ]),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () async {
                                                              await FirebaseAuth.instance.currentUser!.reload();
                                                              await FirebaseAuth.instance.currentUser!.delete();
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text(
                                                              "Cancel",
                                                              style: TextStyle(
                                                                  color: Theme.of(context).colorScheme.secondary),
                                                            )),
                                                        TextButton(
                                                            onPressed: verified
                                                                ? () {
                                                                    Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder: (context) => const EnterDetailsPage(),
                                                                      ),
                                                                    );
                                                                  }
                                                                : null,
                                                            child: Text(
                                                              "Continue",
                                                              style: TextStyle(
                                                                  color: verified
                                                                      ? Theme.of(context).colorScheme.secondary
                                                                      : Theme.of(context).colorScheme.onSurfaceVariant),
                                                            )),
                                                      ],
                                                    );
                                                  });
                                                });
                                          },
                                          child: Text(
                                            "Now",
                                            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                          ))
                                    ],
                                  );
                                });
                          }
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
