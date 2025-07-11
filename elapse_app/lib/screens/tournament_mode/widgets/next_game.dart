import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/extras/twelve_hour.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class NextGame extends StatelessWidget {
  const NextGame(
      {super.key,
      required this.game,
      required this.games,
      required this.skills,
      required this.rankings,
      this.targetTeam,
      this.delay,
      this.numGames});
  final Game game;
  final List<Game> games;
  final TeamPreview? targetTeam;
  final Map<int, TournamentSkills> skills;
  final Map<int, TeamStats> rankings;
  final int? delay;
  final int? numGames;

  @override
  Widget build(BuildContext context) {
    String timeString;
    if (game.startedTime != null) {
      timeString = twelveHour(DateFormat.Hm().format(game.startedTime!.toLocal()));
    } else if (game.scheduledTime != null && game.startedTime == null) {
      timeString = twelveHour(DateFormat.Hm().format(game.scheduledTime!.toLocal()));
    } else {
      timeString = "No Time";
    }
    Color backgroundColor = Theme.of(context).colorScheme.tertiary;

    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }

    bool isBlue(String teamNumber) {
      return game.blueAlliancePreview!.any((element) => element.teamNumber == teamNumber);
    }

    bool isRed(String teamNumber) {
      return game.redAlliancePreview!.any((element) => element.teamNumber == teamNumber);
    }

    if (targetTeam != null) {
      if (isBlue(targetTeam!.teamNumber)) {
        backgroundColor = colorPallete.blueAllianceBackground;
      } else if (isRed(targetTeam!.teamNumber)) {
        backgroundColor = colorPallete.redAllianceBackground;
      }
    }

    Game? currGame = games.lastWhereOrNull((e) => (e.redScore != 0 && e.blueScore != 0) || e.startedTime != null);
    int gamesLeft = games.indexOf(game);
    if (currGame != null) {
      gamesLeft -= games.indexOf(currGame);
    }
    // int gamesLeft = game.gameNum - currGame.gameNum;

    Widget gameText;
    if (game.gameName.substring(0, 1) == "R") {
      gameText = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text("R",
            style: TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
            )),
        Text("16",
            style: TextStyle(
              fontSize: 40,
              height: 1.15,
              letterSpacing: -1,
              fontWeight: FontWeight.w400,
            )),
        Text(game.gameName.substring(3, 4),
            style: TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
            ))
      ]);
    } else {
      gameText = Text(game.gameName,
          style: TextStyle(
            letterSpacing: -1.75,
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w400,
          ));
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return GameScreen(
            game: game,
          );
        }));
      },
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    gameText,
                    const Text(
                      "Next Match",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: game.redAlliancePreview!.map((e) {
                    return Text(
                      e.teamNumber,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: e.teamNumber == targetTeam?.teamNumber ? FontWeight.w500 : FontWeight.normal),
                    );
                  }).toList(),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: game.blueAlliancePreview!.map((e) {
                    return Text(
                      e.teamNumber,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: e.teamNumber == targetTeam?.teamNumber ? FontWeight.w600 : FontWeight.normal),
                    );
                  }).toList(),
                )
              ],
            ),
            SizedBox(height: 10),
            Divider(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
              height: 3,
            ),
            SizedBox(height: 10, width: 50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        "Time",
                        style: TextStyle(fontSize: 16),
                      ),
                    ]),
                    Spacer(),
                    Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, 
                      children: [
                        Text(
                          "$gamesLeft",
                          style: const TextStyle(
                            fontSize: 24,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const Text(
                          "Matches Remaining",
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.right,
                        ),  
                      ])
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    game.fieldName ?? "N/A",
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    "Field",
                    style: TextStyle(fontSize: 16),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
