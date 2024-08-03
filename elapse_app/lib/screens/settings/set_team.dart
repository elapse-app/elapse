import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/providers/color_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetMainTeam extends StatefulWidget {
  const SetMainTeam({super.key, required this.prefs});
  final SharedPreferences prefs;

  @override
  State<SetMainTeam> createState() => _SetMainTeamState();
}

class _SetMainTeamState extends State<SetMainTeam> {
  String teamName = "";
  Future<List<TeamPreview>>? teamSearch;

  String searchQuery = "";

  void searchTeam() {
    setState(() {
      teamSearch = fetchTeamPreview(searchQuery);
    });
  }

  void saveTeam(TeamPreview team) {
    List<String> savedTeams = widget.prefs.getStringList("savedTeams") ?? [];
    print(savedTeams);
    savedTeams.remove(
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    print(savedTeams);
    widget.prefs.setStringList("savedTeams", savedTeams);
    widget.prefs.setString("savedTeam",
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    widget.prefs.setBool("isTournamentMode", false);
    myAppKey.currentState!.reloadApp();
    Navigator.pop(
      context,
    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  IconButton(
                      padding: EdgeInsets.only(right: 10, bottom: 10, top: 10),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      highlightColor: Colors.transparent,
                      icon: Icon(Icons.arrow_back, size: 48)),
                  const Text(
                    "Set your Main Team",
                    style: TextStyle(
                        fontSize: 64, fontWeight: FontWeight.w500, height: 1),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Enter your team number below",
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
                          textInputAction: TextInputAction.search,
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                              hintText: "Enter your team"),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: TextButton(
                          child: Text("Search",
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      Theme.of(context).colorScheme.secondary)),
                          onPressed: searchTeam,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      Spacer(),
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
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary)),
                                    onPressed: () {
                                      saveTeam(snapshot.data![0]);
                                    },
                                    child: const Text(
                                      "Save Team",
                                      style: TextStyle(fontSize: 18),
                                    ));
                              }
                            } else {
                              return Container();
                            }
                          }),
                      Spacer(),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
