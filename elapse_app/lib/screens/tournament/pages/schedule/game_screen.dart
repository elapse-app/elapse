import 'dart:math';

import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
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
                  height: 275,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
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
                                const Text(
                                  "Match Number",
                                  style: TextStyle(fontSize: 16, height: 1),
                                ),
                              ],
                            ),
                            status == "Played"
                                ? Row(children: [
                                    Text(
                                      game.redScore.toString(),
                                      style: TextStyle(
                                          fontSize: 52,
                                          height: 1,
                                          color: colorPallete.redAllianceText),
                                    ),
                                    Text(
                                      "-",
                                      style: TextStyle(fontSize: 40),
                                    ),
                                    Text(
                                      game.blueScore.toString(),
                                      style: TextStyle(
                                          fontSize: 52,
                                          height: 1,
                                          color: colorPallete.blueAllianceText),
                                    ),
                                  ])
                                : Spacer(),
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
                                  Text(time,
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
                        Text(status, style: TextStyle(fontSize: 16, height: 1))
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
                      const Text(
                        "Red Alliance",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: game.redAllianceNum!.map(
                          (e) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e,
                                        style: TextStyle(
                                            fontSize: 40,
                                            height: 1,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                colorPallete.redAllianceText),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Rank",
                                              style: TextStyle(
                                                  color: colorPallete
                                                      .redAllianceText)),
                                          Text("Record",
                                              style: TextStyle(
                                                  color: colorPallete
                                                      .redAllianceText))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Color.fromRGBO(123, 123, 123, 1),
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
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Blue Alliance",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: game.blueAllianceNum!.map(
                          (e) {
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e,
                                        style: TextStyle(
                                            fontSize: 40,
                                            height: 1,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                colorPallete.blueAllianceText),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Rank",
                                              style: TextStyle(
                                                  color: colorPallete
                                                      .blueAllianceText)),
                                          Text("Record",
                                              style: TextStyle(
                                                  color: colorPallete
                                                      .blueAllianceText))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Color.fromRGBO(123, 123, 123, 1),
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
