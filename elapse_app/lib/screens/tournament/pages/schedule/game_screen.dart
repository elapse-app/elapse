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
    required this.divisionId,
    required this.roundNum,
    required this.gameNum,
    required this.instance,
  });

  final int divisionId;
  final num roundNum;
  final int gameNum;
  final int instance;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Game? _game;
  List<Team> teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final tournamentId = prefs.getInt("tournamentID");
    if (tournamentId != null && tournamentId != 0) {
      final tournament = await getTournamentFromCache(tournamentId);
      if (tournament != null && mounted) {
        teams = tournament.teams;
        // Find the game using composite key
        for (final division in tournament.divisions) {
          if (division.id == widget.divisionId && division.games != null) {
            for (final game in division.games!) {
              if (game.roundNum == widget.roundNum &&
                  game.gameNum == widget.gameNum &&
                  game.instance == widget.instance) {
                _game = game;
                break;
              }
            }
            break;
          }
        }
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            ElapseAppBar(
              title: Text("Game Info", style: const TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w600)),
              backNavigation: true,
            ),
            const RoundedTop(),
            SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    if (_game == null) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            ElapseAppBar(
              title: Text("Game Info", style: const TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w600)),
              backNavigation: true,
            ),
            const RoundedTop(),
            SliverFillRemaining(
              child: Center(child: Text("Game not found")),
            ),
          ],
        ),
      );
    }

    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }
    String time = "No Time";
    if (_game!.startedTime != null) {
      time = DateFormat.Hm().format(_game!.startedTime!.toLocal());
    }
    if (_game!.scheduledTime != null) {
      time = DateFormat.Hm().format(_game!.scheduledTime!.toLocal());
    }

    String status = "Not played";
    if ((_game!.redScore != 0 && _game!.blueScore != 0) || _game!.startedTime != null) {
      status = "Played";
    }

    Widget gameText;
    final gameName = _game!.gameName;
    if (gameName.startsWith("R") && gameName.length >= 4) {
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
        Text(gameName.substring(3, 4),
            style: const TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
            ))
      ]);
    } else {
      gameText = Text(gameName,
          style: const TextStyle(
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w400,
          ));
    }

    Color gameColor = Theme.of(context).colorScheme.tertiary;

    if ((_game!.redScore ?? 0) > (_game!.blueScore ?? 0)) {
      gameColor = colorPallete.redAllianceBackground;
    } else if ((_game!.redScore ?? 0) < (_game!.blueScore ?? 0)) {
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
                              Text(_game!.fieldName ?? "",
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
                          Text(_game!.redScore?.toString() ?? "",
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
                      if (_game!.redAlliancePreview != null)
                        Column(
                          children: _game!.redAlliancePreview!.map(
                            (e) {
                              final teamName = teams.where((t) => t.id == e.teamID).firstOrNull?.teamName ?? "";
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
                          Text(_game!.blueScore?.toString() ?? "",
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
                      if (_game!.blueAlliancePreview != null)
                        Column(
                          children: _game!.blueAlliancePreview!.map(
                            (e) {
                              final teamName = teams.where((t) => t.id == e.teamID).firstOrNull?.teamName ?? "";
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
                            },
                          ).toList(),
                        ),
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
