import 'dart:convert';

import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/extras/twelve_hour.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Team> teams = [];
  void initState() {
    super.initState();
    Tournament tournament = loadTournament(prefs.getString("recently-opened-tournament"));
    teams = tournament.teams;
  }

  @override
  Widget build(BuildContext context) {
    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }
    String time = "No Time";
    if (widget.game.startedTime != null) {
      time = DateFormat.Hm().format(widget.game.startedTime!.toLocal());
    }
    if (widget.game.scheduledTime != null) {
      time = DateFormat.Hm().format(widget.game.scheduledTime!.toLocal());
    }

    String status = "Not played";
    if ((widget.game.redScore != 0 && widget.game.blueScore != 0) || widget.game.startedTime != null) {
      status = "Played";
    }

    Widget gameText;
    if (widget.game.gameName.substring(0, 1) == "R") {
      gameText = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text("R",
            style: TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
            )),
        const Text("16",
            style: TextStyle(
              fontSize: 32,
              height: 1.25,
              letterSpacing: -1,
              fontWeight: FontWeight.w500,
            )),
        Text(widget.game.gameName.substring(3, 4),
            style: const TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
            ))
      ]);
    } else {
      gameText = Text(widget.game.gameName,
          style: const TextStyle(
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w400,
          ));
    }

    Color gameColor = Theme.of(context).colorScheme.tertiary;

    if ((widget.game.redScore ?? 0) > (widget.game.blueScore ?? 0)) {
      gameColor = colorPallete.redAllianceBackground;
    } else if ((widget.game.redScore ?? 0) < (widget.game.blueScore ?? 0)) {
      gameColor = colorPallete.blueAllianceBackground;
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: Text("Game Info", style: const TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w600)),
            backNavigation: true,
          ),
          const RoundedTop(),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: 220,
                  decoration: BoxDecoration(color: gameColor, borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                gameText,
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  status,
                                  style: const TextStyle(fontSize: 16, height: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("Start Time", style: TextStyle(fontSize: 24, height: 1)),
                              Text(twelveHour(time),
                                  style: const TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w500))
                            ]),
                            SizedBox(
                              height: 20,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("Field", style: TextStyle(fontSize: 24, height: 1)),
                              Text(widget.game.fieldName ?? "",
                                  style: const TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w500))
                            ])
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Red Alliance",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(widget.game.redScore?.toString() ?? "",
                              style: TextStyle(
                                  fontSize: 32,
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                  color: colorPallete.redAllianceText))
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Column(
                        children: widget.game.redAlliancePreview!.map(
                          (e) {
                            {
                              String teamName = "";
                              for (Team team in teams) {
                                if (team.id == e.teamID) {
                                  teamName = team.teamName ?? "";
                                }
                              }
                              return Column(
                                children: [
                                  RankingsWidget(
                                      teamID: e.teamID,
                                      teamNumber: e.teamNumber,
                                      teamName: teamName,
                                      allianceColor: colorPallete.redAllianceText),
                                  Divider(
                                    color: Theme.of(context).colorScheme.surfaceDim,
                                    thickness: 1,
                                  )
                                ],
                              );
                            }
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 28,
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Blue Alliance",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(widget.game.blueScore?.toString() ?? "",
                              style: TextStyle(
                                  fontSize: 32,
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                  color: colorPallete.blueAllianceText))
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: widget.game.blueAlliancePreview!.map(
                          (e) {
                            {
                              String teamName = "";
                              for (Team team in teams) {
                                if (team.id == e.teamID) {
                                  teamName = team.teamName ?? "";
                                }
                              }
                              return Column(
                                children: [
                                  RankingsWidget(
                                      teamID: e.teamID,
                                      teamNumber: e.teamNumber,
                                      teamName: teamName,
                                      allianceColor: colorPallete.blueAllianceText),
                                  Divider(
                                    color: Theme.of(context).colorScheme.surfaceDim,
                                    thickness: 1,
                                  )
                                ],
                              );
                            }
                          },
                        ).toList(),
                      ),
                      Row(
                        children: [Text("")],
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
