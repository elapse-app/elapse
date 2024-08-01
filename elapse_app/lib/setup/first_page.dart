import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:elapse_app/setup/theme_setup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstSetupPage extends StatefulWidget {
  const FirstSetupPage({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<FirstSetupPage> createState() => _FirstSetupPageState();
}

class _FirstSetupPageState extends State<FirstSetupPage> {
  String teamName = "";
  Future<List<TeamPreview>>? teamSearch;

  void _onSearchSubmitted(String value) {
    setState(() {
      teamName = value;
      teamSearch = fetchTeamPreview(teamName);
    });
  }

  void saveTeam(TeamPreview team) {
    widget.prefs.setString("savedTeam",
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ThemeSetup(
                  prefs: widget.prefs,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, snapshot) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23.0),
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  const Text(
                    "Welcome to Elapse!",
                    style: TextStyle(
                        fontSize: 64, fontWeight: FontWeight.w500, height: 1),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Enter your team number below to get started",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: _onSearchSubmitted,
                    cursorColor: Theme.of(context).colorScheme.secondary,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                    decoration:
                        const InputDecoration(hintText: "Enter your team"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FutureBuilder(
                      future: teamSearch,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        }
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return Text(
                              "No teams found",
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.75),
                                  fontSize: 18),
                            );
                          } else {
                            return TextButton(
                                style: ButtonStyle(
                                    foregroundColor: WidgetStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary)),
                                onPressed: () {
                                  saveTeam(snapshot.data![0]);
                                },
                                child: const Text(
                                  "Save and Continue",
                                  style: TextStyle(fontSize: 18),
                                ));
                          }
                        } else {
                          return Container();
                        }
                      })
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
