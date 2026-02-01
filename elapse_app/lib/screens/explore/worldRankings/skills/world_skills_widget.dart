import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills_page.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/world_skills.dart';

class WorldSkillsWidget extends StatelessWidget {
  const WorldSkillsWidget({
    super.key,
    required this.stats,
    required this.rank,
    this.sort = 0,
  });

  final WorldSkillsStats stats;
  final int rank;
  final int sort;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        worldSkillsPage(context, stats.teamId, stats.teamNum, stats.teamName, stats);
      },
      child: Container(
          height: 72,
          alignment: Alignment.center,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stats.teamNum,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 32,
                                height: 1,
                                letterSpacing: -1.5,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface)),
                        Text(stats.teamName,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: Theme.of(context).colorScheme.onSurfaceVariant))
                      ]),
                ),
                SizedBox(
                  height: 50,
                  width: 20,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Rank $rank",
                              style: const TextStyle(
                                fontSize: 16,
                              )),
                          Text("${stats.score} pts",
                              style: const TextStyle(
                                fontSize: 16,
                              )),
                        ],
                      ),
                      sort >= 3
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Text("↑", style: TextStyle(fontSize: 16, fontFamily: "Manrope"))
                                      ]),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        // Icon(Icons.arrow_upward),
                                        Text("↑", style: TextStyle(fontSize: 16, fontFamily: "Manrope"))
                                      ]),
                                ])
                          : const SizedBox(),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sort <= 2
                                    ? Text("${stats.driver}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ))
                                    : Text("${stats.maxDriver}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        )),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(Icons.sports_esports_outlined),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sort <= 2
                                    ? Text("${stats.auton}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ))
                                    : Text("${stats.maxAuton}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                        )),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(Icons.data_object),
                              ],
                            ),
                          ])
                    ],
                  ),
                ),
              ])),
    );
  }
}
