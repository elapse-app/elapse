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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => GameScreen(
                      game: widget.game,
                      colorPallete: colorPallete,
                    )));
      },
      child: Container(
        height: 55,
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 95,
                  child: Text(
                    widget.game.gameName,
                    style: const TextStyle(
                        fontSize: 32, height: 1, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        widget.game.fieldName ?? "",
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1,
                            fontWeight: FontWeight.w300),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 75,
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
                  }).toList()),
            ),
            SizedBox(
              width: 75,
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
          ],
        ),
      ),
    );
  }
}
