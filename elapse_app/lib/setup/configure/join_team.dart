import 'dart:convert';

import 'package:elapse_app/classes/Users/user.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/main.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({
    super.key,
  });

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  _JoinTeamPageState();
  final TextEditingController _teamController = TextEditingController();
  Future<List<TeamPreview>>? teamSearch;
  String searchQuery = "";
  String buttonLabel = "Search";
  TeamPreview? selectedTeam;

  void searchTeam() async {
    setState(() {
      searchQuery = _teamController.text;
      teamSearch = fetchTeamPreview(searchQuery);
    });

    final teams = await teamSearch;
    if (teams != null && teams.isNotEmpty) {
      setState(() {
        selectedTeam = teams.first;
        buttonLabel = "Confirm";
      });
    } else {
      setState(() {
        selectedTeam = null;
        buttonLabel = "Search";
      });
    }
  }

  void saveTeam(TeamPreview team) {
    prefs.setString("savedTeam", '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    Navigator.push(context, MaterialPageRoute(builder: (context) => EnterDetailsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                  padding: const EdgeInsets.all(0.0),
                  child: Column(
                    children: [
                      SizedBox(height: 46),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Team details',
                              style: TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.secondary,
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
                              text: 'Get personalized info for your team',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Manrope",
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                        child: TextFormField(
                          controller: _teamController,
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
                            labelText: 'Team Number',
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Manrope",
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      SizedBox(
<<<<<<< HEAD
                        height: 30,
                        child: FutureBuilder<List<TeamPreview>>(
                          future: teamSearch,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return SizedBox.shrink();
                              case ConnectionState.waiting:
                              case ConnectionState.active:
                                return SizedBox(
                                  width: 30,
                                  child: CircularProgressIndicator(),
                                );
                              case ConnectionState.done:
                                return Text("Press confirm to continue");
                            }
                          },
                        )
                      ),
=======
                          height: 30,
                          child: FutureBuilder<List<TeamPreview>>(
                            future: teamSearch,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return SizedBox.shrink();
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  return SizedBox(
                                    width: 30,
                                    child: CircularProgressIndicator(),
                                  );
                                case ConnectionState.done:
                                  return Text("Press confirm to continue");
                              }
                            },
                          )),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                      SizedBox(height: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 23),
                        child: LongButton(
                          centerAlign: true,
                          useForwardArrow: false,
                          onPressed: () async {
                            if (buttonLabel == "Search") {
                              searchTeam();
                            } else if (buttonLabel == "Confirm" && selectedTeam != null) {
                              prefs.setString("savedTeam", jsonEncode(selectedTeam!.toJson()));
                              if (prefs.getString("currentUser") == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThemeSetup(),
                                  ),
                                );
                                return;
                              }

                              ElapseUser currentUser = ElapseUser.fromJson(jsonDecode(prefs.getString("currentUser")!));
                              currentUser.teamNumber = selectedTeam!.teamNumber;
                              prefs.setString("currentUser", jsonEncode(currentUser.toJson()));
                              Database database = Database();
                              await database.createUser(currentUser, selectedTeam!).then((value) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ThemeSetup(),
                                  ),
                                );
                              }).catchError((onError) {
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
                            }
                          },
                          text: buttonLabel,
                        ),
                      ),
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
