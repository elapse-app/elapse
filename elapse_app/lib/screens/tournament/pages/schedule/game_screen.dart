import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.game, required this.colorPallete});

  final Game game;
  final ColorPallete colorPallete;

  @override
  Widget build(BuildContext context) {
    String time = "";
    if (game.startedTime != null) {
      time = DateFormat.Hm().format(game.startedTime!);
    }
    if (game.scheduledTime != null) {
      time = DateFormat.Hm().format(game.scheduledTime!);
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
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.gameName,
                              style: const TextStyle(fontSize: 64, height: 1),
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
                        Text("Not played",
                            style: TextStyle(fontSize: 16, height: 1))
                      ],
                    ),
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
