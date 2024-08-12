import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/extras/twelve_hour.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.game,
  });

  final Game game;

  @override
  Widget build(BuildContext context) {
    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }
    String time = "No Time";
    if (game.startedTime != null) {
      time = DateFormat.Hm().format(game.startedTime!.toLocal());
    }
    if (game.scheduledTime != null) {
      time = DateFormat.Hm().format(game.scheduledTime!.toLocal());
    }

    String status = "Not played";
    if ((game.redScore != 0 && game.blueScore != 0) ||
        game.startedTime != null) {
      status = "Played";
    }

    Widget gameText;
    if (game.gameName.substring(0, 1) == "R") {
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
        Text(game.gameName.substring(3, 4),
            style: const TextStyle(
              fontSize: 64,
              height: 1,
              fontWeight: FontWeight.w400,
            ))
      ]);
    } else {
      gameText = Text(game.gameName,
          style: const TextStyle(
            fontSize: 64,
            height: 1,
            fontWeight: FontWeight.w400,
          ));
    }

    Color gameColor = Theme.of(context).colorScheme.tertiary;

    if ((game.redScore ?? 0) > (game.blueScore ?? 0)) {
      gameColor = colorPallete.redAllianceBackground;
    } else if ((game.redScore ?? 0) < (game.blueScore ?? 0)) {
      gameColor = colorPallete.blueAllianceBackground;
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 125,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: EdgeInsets.only(left: 20, right: 12),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back)),
                    const Text(
                      "Match Info",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          const RoundedTop(),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 25),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                      color: gameColor,
                      borderRadius: BorderRadius.circular(18)),
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
                                  style:
                                      const TextStyle(fontSize: 16, height: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Start Time",
                                      style:
                                          TextStyle(fontSize: 24, height: 1)),
                                  Text(twelveHour(time),
                                      style: const TextStyle(
                                          fontSize: 24,
                                          height: 1,
                                          fontWeight: FontWeight.w500))
                                ]),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Field",
                                      style:
                                          TextStyle(fontSize: 24, height: 1)),
                                  Text(game.fieldName ?? "",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          height: 1,
                                          fontWeight: FontWeight.w500))
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
                          Text(game.redScore?.toString() ?? "",
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
                        children: game.redAlliancePreview!.map(
                          (e) {
                            {
                              return Column(
                                children: [
                                  StandardRanking(
                                      teamID: e.teamID,
                                      teamNumber: e.teamNumber,
                                      allianceColor:
                                          colorPallete.redAllianceText),
                                  Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
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
                          Text(game.blueScore?.toString() ?? "",
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
                        children: game.blueAlliancePreview!.map(
                          (e) {
                            {
                              return Column(
                                children: [
                                  StandardRanking(
                                      teamID: e.teamID,
                                      teamNumber: e.teamNumber,
                                      allianceColor:
                                          colorPallete.blueAllianceText),
                                  Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
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
