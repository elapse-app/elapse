import 'dart:math';

import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/extras/twelve_hour.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.game, required this.rankings});

  final Game game;
  final Map<int, TeamStats>? rankings;

  @override
  Widget build(BuildContext context) {
    print(rankings);
    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }
    String time = "";
    if (game.startedTime != null) {
      time = DateFormat.Hm().format(game.startedTime!);
    }
    if (game.scheduledTime != null) {
      time = DateFormat.Hm().format(game.scheduledTime!);
    }

    String status = "Not played";
    if (game.redScore != null) {
      status = "Played";
    }

    Color dividerColor =
        Theme.of(context).colorScheme.brightness == Brightness.dark
            ? const Color.fromARGB(255, 55, 55, 55)
            : const Color.fromARGB(255, 211, 211, 211);
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
              background: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 12, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          SettingsButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                      color: Theme.of(context).colorScheme.tertiary,
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
                                Text(
                                  game.gameName,
                                  style:
                                      const TextStyle(fontSize: 64, height: 1),
                                ),
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
                            return Column(
                              children: [
                                Container(
                                  height: 72,
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 120,
                                        fit: FlexFit.tight,
                                        child: Text(e.teamName,
                                            style: TextStyle(
                                                fontSize: 40,
                                                height: 1,
                                                fontWeight: FontWeight.w400,
                                                color: colorPallete
                                                    .redAllianceText)),
                                      ),
                                      Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Rank ${rankings![e.teamID]!.rank}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                )),
                                            Text(
                                                "${rankings![e.teamID]!.wins}-${rankings![e.teamID]!.losses}-${rankings![e.teamID]!.ties}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        flex: 20,
                                        fit: FlexFit.tight,
                                        child: Container(
                                            height: 50,
                                            child: VerticalDivider(
                                              thickness: 0.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                            )),
                                      ),
                                      Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                "${rankings![e.teamID]!.wp} WP",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                            Text(
                                                "${rankings![e.teamID]!.ap} AP",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: dividerColor,
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
                            return Column(
                              children: [
                                Container(
                                  height: 72,
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 120,
                                        fit: FlexFit.tight,
                                        child: Text(e.teamName,
                                            style: TextStyle(
                                                fontSize: 40,
                                                height: 1,
                                                fontWeight: FontWeight.w400,
                                                color: colorPallete
                                                    .blueAllianceText)),
                                      ),
                                      Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                "Rank ${rankings![e.teamID]!.rank}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                )),
                                            Text(
                                                "${rankings![e.teamID]!.wins}-${rankings![e.teamID]!.losses}-${rankings![e.teamID]!.ties}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                      ),
                                      Flexible(
                                        flex: 20,
                                        fit: FlexFit.tight,
                                        child: Container(
                                            height: 50,
                                            child: VerticalDivider(
                                              thickness: 0.5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                            )),
                                      ),
                                      Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                                "${rankings![e.teamID]!.wp} WP",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                )),
                                            Text(
                                                "${rankings![e.teamID]!.ap} AP",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: dividerColor,
                                  thickness: 1,
                                )
                              ],
                            );
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
