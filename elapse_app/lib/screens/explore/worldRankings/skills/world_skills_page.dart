import 'package:flutter/material.dart';

import '../../../../classes/Team/world_skills.dart';
import '../../../team_screen/team_screen.dart';

Future<void> worldSkillsPage(
    BuildContext context, int teamID, String teamNum, String teamName, WorldSkillsStats stats) {
  final DraggableScrollableController dra = DraggableScrollableController();

  return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.6,
            minChildSize: 0,
            expand: false,
            shouldCloseOnMinExtent: true,
            snapAnimationDuration: const Duration(milliseconds: 250),
            controller: dra,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 23, vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView(controller: scrollController, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$teamNum Skills",
                              style: const TextStyle(
                                fontSize: 24,
                                height: 1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              teamName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ]
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamScreen(
                                  teamID: teamID,
                                  teamNumber: teamNum,
                                ),
                              ),
                            );
                          },
                          child: Text(
                                "View More",
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
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
                          color: Theme.of(context).colorScheme.primary),
                      padding: const EdgeInsets.all(18),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${stats.rank}",
                                    style: const TextStyle(
                                        fontSize: 64,
                                        letterSpacing: -2,
                                        height: 1),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Text(
                                    "World Skills Rank",
                                    style: TextStyle(fontSize: 16, height: 1),
                                  ),
                                ]),
                          ],
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        Row(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${stats.score}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    )),
                                const SizedBox(height: 4),
                                const Text("Total",
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                              ]),
                          const SizedBox(
                            width: 30,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${stats.driver}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    )),
                                const SizedBox(height: 4),
                                const Text("Driver",
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                              ]),
                          const SizedBox(
                            width: 30,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${stats.auton}",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                      height: 1,
                                    )),
                                const SizedBox(height: 4),
                                const Text("Auton",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                    )),
                              ]),
                        ]),
                        const SizedBox(
                          height: 18,
                        ),
                        const Divider(
                          height: 3,
                        ),
                        const SizedBox(
                          height: 18,
                        ),
                        Row(children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${stats.maxDriver}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  "↑ Driver",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ]),
                          const SizedBox(
                            width: 18,
                          ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${stats.maxAuton}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Text(
                                  "↑ Auton",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ]),
                        ])
                      ]),
                    ),
                  ]));
            });
      });
}
