import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournament_mode_functions.dart';
import 'package:elapse_app/extras/twelve_hour.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({
    super.key,
    required this.divisionId,
    required this.roundNum,
    required this.gameNum,
    required this.instance,
    this.teamName,
    this.isAllianceColoured,
    this.useLiveTiming,
  });

  final int divisionId;
  final num roundNum;
  final int gameNum;
  final int instance;
  final String? teamName;
  final bool? isAllianceColoured;
  final bool? useLiveTiming;

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  Game? _game;
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
    if (_isLoading || _game == null) {
      return const SizedBox.shrink();
    }
    final game = _game!;
    String time = "No Time";
    if (game.startedTime != null) {
      time = DateFormat.Hm().format(game.startedTime!.toLocal());
    }
    if (game.scheduledTime != null && game.startedTime == null) {
      DateTime start;
      if (widget.useLiveTiming == true) {
        start = (game.adjustedTime ?? game.scheduledTime!).toLocal();
        time = DateFormat.Hm().format(start);
      } else {
        start = game.scheduledTime!.toLocal();
        time = DateFormat.Hm().format(start);
      }
    }

    time = twelveHour(time);

    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }

    String winningAlliance = "none";
    Color gameColor = Theme.of(context).colorScheme.onSurface;

    if (game.blueScore != null && game.redScore != null) {
      if (game.blueScore! > game.redScore!) {
        gameColor = colorPallete.blueAllianceText;
        winningAlliance = "blue";
      } else if (game.blueScore! < game.redScore!) {
        gameColor = colorPallete.redAllianceText;
        winningAlliance = "red";
      }
    }

    if (widget.isAllianceColoured == false) {
      gameColor = Theme.of(context).colorScheme.onSurface;
    } else {
      if (game.redAlliancePreview?.any((element) => element.teamNumber == widget.teamName) ?? false) {
        gameColor = colorPallete.redAllianceText;
      } else if (game.blueAlliancePreview?.any((element) => element.teamNumber == widget.teamName) ?? false) {
        gameColor = colorPallete.blueAllianceText;
      }
    }

    if (winningAlliance == "red" && (game.redAlliancePreview?.any((element) => element.teamNumber == widget.teamName) ?? false)) {
      gameColor = colorPallete.greenText;
    } else if (winningAlliance == "blue" &&
        (game.blueAlliancePreview?.any((element) => element.teamNumber == widget.teamName) ?? false)) {
      gameColor = colorPallete.greenText;
    } else if (winningAlliance != "none" && widget.teamName != null) {
      gameColor = colorPallete.redAllianceText;
    }

    Widget gameText;
    final gameName = game.gameName;
    if (gameName.startsWith("R") && gameName.length >= 4) {
      gameText = Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text("R",
            style: TextStyle(
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w400,
              color: gameColor,
            )),
        Text("16",
            style: TextStyle(
              fontSize: 20,
              height: 1.3,
              letterSpacing: -1,
              fontWeight: FontWeight.w400,
              color: gameColor,
            )),
        Text(gameName.substring(3, 4),
            style: TextStyle(
              color: gameColor,
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w400,
            ))
      ]);
    } else {
      gameText = Text(gameName,
          style: TextStyle(
            letterSpacing: -1.75,
            fontSize: 40,
            height: 1,
            color: gameColor,
            fontWeight: FontWeight.w400,
          ));
    }

    Color timeColor = Theme.of(context).colorScheme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 168, 168, 168)
        : const Color.fromARGB(255, 118, 118, 118);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              divisionId: game.divisionId,
              roundNum: game.roundNum,
              gameNum: game.gameNum,
              instance: game.instance,
            ),
          ),
        );
      },
      child: Container(
        height: 72,
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 120,
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 65,
                    child: gameText,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: TextStyle(fontSize: 16, height: 1, color: timeColor),
                          maxLines: 1,
                        ),
                        (game.redScore != 0 && game.blueScore != 0) || game.startedTime != null
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    game.redScore.toString(),
                                    style: TextStyle(
                                        color: colorPallete.redAllianceText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1),
                                  ),
                                  Text("-",
                                      style: TextStyle(
                                          color: timeColor, fontSize: 16, fontWeight: FontWeight.w500, height: 1)),
                                  Text(
                                    game.blueScore.toString(),
                                    style: TextStyle(
                                        color: colorPallete.blueAllianceText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1),
                                  ),
                                ],
                              )
                            : Text(game.fieldName ?? "",
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 16, height: 1, color: timeColor, overflow: TextOverflow.ellipsis))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 25,
              child: Container(
                  height: 50,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.tertiary,
                  )),
            ),
            Flexible(
              fit: FlexFit.tight,
              flex: 88,
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (game.redAlliancePreview ?? []).map(
                        (e) {
                          return Text(
                            e.teamNumber,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1,
                                fontWeight: FontWeight.w500,
                                color: colorPallete.redAllianceText),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: (game.blueAlliancePreview ?? []).map(
                        (e) {
                          return Text(
                            e.teamNumber,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1,
                                fontWeight: FontWeight.w500,
                                color: colorPallete.blueAllianceText),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
