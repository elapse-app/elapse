import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elapse_app/main.dart';

class FirstSetupPage extends StatefulWidget {
  const FirstSetupPage({super.key});

  @override
  State<FirstSetupPage> createState() => _FirstSetupPageState();
}

class _FirstSetupPageState extends State<FirstSetupPage> {
  String teamName = "";
  Future<List<TeamPreview>>? teamSearch;
  String searchQuery = "";

  void searchTeam() {
    setState(() {
      teamSearch = fetchTeamPreview(searchQuery);
    });
  }

  void saveTeam(TeamPreview team) {
    prefs.setString("savedTeam",
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}", "grade": "${team.gradeLevel?.name}"}');
    prefs.setString("defaultGrade", "Main Team");
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => ThemeSetup()));
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
<<<<<<< HEAD
                    style: TextStyle(
                        fontSize: 64, fontWeight: FontWeight.w500, height: 1),
=======
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.w500, height: 1),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        flex: 3,
                        child: TextField(
                          textInputAction: TextInputAction.go,
                          onChanged: ((value) {
                            setState(() {
                              searchQuery = value;
                            });
                          }),
                          cursorColor: Theme.of(context).colorScheme.secondary,
<<<<<<< HEAD
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                              hintText: "Enter your team"),
=======
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(hintText: "Enter your team"),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          child: Text("Search",
<<<<<<< HEAD
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
=======
                              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.secondary)),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                          onPressed: searchTeam,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  FutureBuilder(
                      future: teamSearch,
                      builder: (context, snapshot) {
<<<<<<< HEAD
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
=======
                        if (snapshot.connectionState == ConnectionState.waiting) {
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                          return Container();
                        }
                        if (snapshot.hasData) {
                          if (snapshot.data!.isEmpty) {
                            return Text(
                              "No teams found",
                              style: TextStyle(
<<<<<<< HEAD
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.75),
                                  fontSize: 18),
=======
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75), fontSize: 18),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                            );
                          } else {
                            return TextButton(
                                style: ButtonStyle(
<<<<<<< HEAD
                                    foregroundColor: WidgetStateProperty.all(
                                        Theme.of(context)
                                            .colorScheme
                                            .secondary)),
=======
                                    foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.secondary)),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
