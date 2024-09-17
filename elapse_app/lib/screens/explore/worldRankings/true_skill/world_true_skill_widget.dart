import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill_page.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/vdaStats.dart';

class WorldTrueSkillWidget extends StatelessWidget {
  const WorldTrueSkillWidget({
    super.key,
    required this.stats,
    this.sort = 0,
  });

  final VDAStats stats;
  final int sort;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        worldTrueSkillPage(context, stats.id, stats.teamNum.isEmpty ? stats.teamName! : stats.teamNum, stats);
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
                    child: Row(children: [
                      Flexible(
                          fit: FlexFit.tight,
                          flex: 25,
                          child: Text(stats.teamNum.isEmpty ? stats.teamName! : stats.teamNum,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 40,
                                  height: 1,
                                  letterSpacing: -1.5,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface))),
                      Flexible(
                        flex: 15,
                        fit: FlexFit.tight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rank ${stats.trueSkillGlobalRank ?? "N/A"}",
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                            Text(stats.trueSkill?.toStringAsFixed(1) ?? "N/A",
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                          ],
                        ),
                      ),
                      Flexible(
                        flex: 15,
                        fit: FlexFit.tight,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sort == 0 || sort >= 3
                                      ? Text("CCWM ${stats.ccwm ?? "N/A"}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ))
                                      : Text("OPR ${stats.opr ?? "N/A"}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  sort == 0 || sort >= 3
                                      ? Text(
                                          "WR ${stats.winPercent?.toInt() ?? 0} %",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ))
                                      : Text("DPR ${stats.dpr ?? "N/A"}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          )),
                                ],
                              ),
                            ]),
                      )
                    ]))
              ])),
    );
  }
}
