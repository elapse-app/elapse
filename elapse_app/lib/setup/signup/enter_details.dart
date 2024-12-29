import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/join_team.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Team/teamPreview.dart';
import '../../extras/database.dart';
import '../configure/theme_setup.dart';

class EnterDetailsPage extends StatefulWidget {
  const EnterDetailsPage({
    super.key,
  });

  @override
  State<EnterDetailsPage> createState() => _EnterDetailsPageState();
}

class _EnterDetailsPageState extends State<EnterDetailsPage> {
  @override
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final firebaseUser = FirebaseAuth.instance.currentUser;
  ElapseUser currentUser = ElapseUser(uid: "", email: "");
  void initState() {
    currentUser = ElapseUser(
      uid: firebaseUser!.uid,
      email: firebaseUser!.email,
      verified: firebaseUser!.emailVerified,
    );
    if (prefs.getString("savedTeam") != null) {
      TeamPreview team = loadTeamPreview(prefs.getString("savedTeam"));
      currentUser.teamNumber = team.teamNumber;
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color.fromARGB(255, 191, 231, 237),
        // appBar: PreferredSize(
        //   preferredSize: MediaQuery.of(context).size * 0.07,
        //   child: AppBar(
        //     automaticallyImplyLeading: false,
        //     backgroundColor: Color.fromARGB(255, 191, 231, 237),
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

        backgroundColor: Theme.of(context).colorScheme.primary,
        body: CustomScrollView(physics: const NeverScrollableScrollPhysics(), slivers: [
          ElapseAppBar(
            title: Text(
              'Sign up',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            maxHeight: 60,
            backNavigation: false,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 46),
                    Center(
                      child: Text(
                        'Enter your details',
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
                        child: RichText(
                          text: TextSpan(
                            text: 'Please fill in the fields below',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontFamily: "Manrope",
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Padding(
                      padding: EdgeInsets.fromLTRB(23, 0, 23, 0),
                      child: TextFormField(
                        controller: _firstNameController,
                        onChanged: (value) {
                          setState(() {
                            currentUser.fname = value;
                          });
                        },
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
                          labelText: 'First Name',
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
                        controller: _lastNameController,
                        onChanged: (value) {
                          setState(() {
                            currentUser.lname = value;
                          });
                        },
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
                          labelText: 'Last Name',
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
                    SizedBox(height: 38),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23.0),
                      child: LongButton(
                        text: "Continue",
                        onPressed: () async {
                          prefs.setString("currentUser", jsonEncode(currentUser.toJson()));

                          if (prefs.getBool("isSetUp") ?? false) {
                            Database database = Database();
                            await database
                                .createUser(currentUser, loadTeamPreview(prefs.getString("savedTeam")))
                                .then((_) => Navigator.of(context)
                                  ..pop()
                                  ..pop())
                                .catchError((onError) {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Error Occured"),
                                      content: Text("An error occured when creating your account, please try again"),
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
                          } else {
                            Navigator.push(
<<<<<<< HEAD
                              context,
                              MaterialPageRoute(
                                builder: (context) => const JoinTeamPage(),
                              )
                            );
=======
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const JoinTeamPage(),
                                ));
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
