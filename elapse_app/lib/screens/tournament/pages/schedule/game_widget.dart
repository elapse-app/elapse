import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key, required this.game});
  final Game game;

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

    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }

    FontWeight blueFontWeight = FontWeight.w500;
    FontWeight redFontWeight = FontWeight.w500;

    if (widget.game.blueScore != null && widget.game.redScore != null) {
      if (widget.game.blueScore! > widget.game.redScore!) {
        blueFontWeight = FontWeight.w700;
      } else if (widget.game.blueScore! < widget.game.redScore!) {
        redFontWeight = FontWeight.w700;
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameScreen(
                      game: widget.game,
                    )));
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 95,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Text(
                    widget.game.gameName,
                    style: const TextStyle(
                        fontSize: 28, height: 1, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 13, height: 1, fontWeight: FontWeight.w400),
                  ),
                  Spacer()
                ],
              ),
            ),
            SizedBox(width: 5),
            Flexible(
              flex: 120,
              child: Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 50,
                    child: Text(
                      widget.game.redScore?.toString() ?? "",
                      style: TextStyle(
                          fontSize: 24,
                          height: 1,
                          fontWeight: redFontWeight,
                          color: colorPallete.redAllianceText),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.game.redAllianceNum!.map((e) {
                        return Text(
                          e,
                          style: TextStyle(
                              fontSize: 16,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              color: colorPallete.redAllianceText),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 120,
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 65,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.game.blueAllianceNum!.map(
                        (e) {
                          return Text(
                            e,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: colorPallete.blueAllianceText),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 45,
                    child: Text(
                      widget.game.blueScore?.toString() ?? "",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 24,
                          height: 1,
                          fontWeight: blueFontWeight,
                          color: colorPallete.blueAllianceText),
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
