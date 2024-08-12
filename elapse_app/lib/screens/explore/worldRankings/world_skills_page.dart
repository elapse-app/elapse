import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../classes/Team/team.dart';
import '../../../classes/Team/vdaStats.dart';
import '../../team_screen/team_screen.dart';

Future<void> worldSkillsPage(BuildContext context, int teamID, String teamNum, VDAStats stats, {Team? team}) {
  final DraggableScrollableController dra = DraggableScrollableController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        minChildSize: 0,
        expand: false,
        shouldCloseOnMinExtent: true,
        snapAnimationDuration: const Duration(milliseconds: 250),
        controller: dra,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$teamNum Skills",
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextButton(
                      iconAlignment: IconAlignment.end,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamScreen(
                              teamID: teamID,
                              teamName: teamNum,
                              team: team,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "View More",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Theme.of(context).colorScheme.primary
                  ),
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${stats.worldSkillsRank}",
                            style: const TextStyle(
                              fontSize: 80,
                              letterSpacing: -2,
                              height: 1
                            ),
                          ),
                          const SizedBox(
                              height: 4
                          ),
                          const Text(
                            "World Skills Rank",
                            style: TextStyle(fontSize: 16, height: 1),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${stats.skillsScore}",
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500,
                              )),
                              const Text("Total",
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500,
                              )),
                            ]
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${stats.maxDriver}",
                                    style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                    )),
                                const Text("Driver",
                                    style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                    )),
                              ]
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${stats.maxAuto}",
                                    style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                    )),
                                const Text("Programming",
                                    style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w500,
                                    )),
                              ]
                          ),
                        ]
                      ),
                    ]
                  ),
                )
              ]
            )
          );
        }
      );
    }
  );
}