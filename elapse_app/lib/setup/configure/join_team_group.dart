import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/complete_setup.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/configure/tournament_mode_setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinTeamGroup extends StatefulWidget {
  const JoinTeamGroup({
    super.key,
  });

  @override
  State<JoinTeamGroup> createState() => _JoinTeamGroupState();
}

class _JoinTeamGroupState extends State<JoinTeamGroup> {
  _JoinTeamGroupState();

  String joinCode = "";

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
                          SizedBox(height: 46),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: 'Join a group.',
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
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text:
                                      'Enter the join code. Make sure to include all characters including the hyphen',
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
                          SizedBox(height: 24),
                          TextField(
                            onChanged: ((value) {
                              setState(() {
                                joinCode = value;
                              });
                            }),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.25),
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
                              labelText: 'Join Code',
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Manrope",
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 32,
                          ),
                          LongButton(
                            text: "Continue",
                            onPressed: () async {
                              Database database = Database();
                              final currentUser =
                                  FirebaseAuth.instance.currentUser;
                              await database
                                  .joinTeamGroup(joinCode, currentUser!.uid)
                                  .then((value) {
                                prefs.setString("teamGroup", value);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompleteSetupPage(),
                                  ),
                                );
                              }).catchError((onError) {
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Error Occured"),
                                        content: Text(
                                            "An error occured when creating your account, please try again"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary),
                                              ))
                                        ],
                                      );
                                    });
                              });
                            },
                          ),
                          SizedBox(height: 38),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]));
  }
}
