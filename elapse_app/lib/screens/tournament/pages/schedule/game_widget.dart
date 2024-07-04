import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/extras/twelve_hour.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key, required this.game, required this.rankings});
  final Game game;
  final Map<int, TeamStats>? rankings;

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  @override
  Widget build(BuildContext context) {
    String time = "";
    if (widget.game.startedTime != null) {
      time = DateFormat.Hm().format(widget.game.startedTime!);
    }
    if (widget.game.scheduledTime != null) {
      time = DateFormat.Hm().format(widget.game.scheduledTime!);
    }

    time = twelveHour(time);

    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }

    Color gameColor = Theme.of(context).colorScheme.onSurface;

    if (widget.game.blueScore != null && widget.game.redScore != null) {
      if (widget.game.blueScore! > widget.game.redScore!) {
        gameColor = colorPallete.blueAllianceText;
      } else if (widget.game.blueScore! < widget.game.redScore!) {
        gameColor = colorPallete.redAllianceText;
      }
    }

    Widget gameText;
    if (widget.game.gameName.substring(0, 1) == "R") {
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
              fontWeight: FontWeight.w400,
              color: gameColor,
            )),
        Text(widget.game.gameName.substring(3, 4),
            style: TextStyle(
              color: gameColor,
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w400,
            ))
      ]);
    } else {
      gameText = Text(widget.game.gameName,
          style: TextStyle(
            letterSpacing: -2,
            fontSize: 40,
            height: 1,
            color: gameColor,
            fontWeight: FontWeight.w400,
          ));
    }

    Color timeColor = Theme.of(context).colorScheme.onSurface;
    if (widget.game.startedTime != null) {
      timeColor = Theme.of(context).colorScheme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 168, 168, 168)
          : const Color.fromARGB(255, 118, 118, 118);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameScreen(
                      game: widget.game,
                      rankings: widget.rankings,
                    )));
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
                          style: TextStyle(
                              fontSize: 16, height: 1, color: timeColor),
                          maxLines: 1,
                        ),
                        widget.game.redScore != null
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.game.redScore.toString(),
                                    style: TextStyle(
                                        color: colorPallete.redAllianceText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1),
                                  ),
                                  Text("-",
                                      style: TextStyle(
                                          color: timeColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          height: 1)),
                                  Text(
                                    widget.game.blueScore.toString(),
                                    style: TextStyle(
                                        color: colorPallete.blueAllianceText,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        height: 1),
                                  ),
                                ],
                              )
                            : Text(widget.game.fieldName!,
                                style: const TextStyle(fontSize: 16, height: 1))
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
                      children: widget.game.redAlliancePreview!.map(
                        (e) {
                          return Text(
                            e.teamName,
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
                      children: widget.game.blueAlliancePreview!.map(
                        (e) {
                          return Text(
                            e.teamName,
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
