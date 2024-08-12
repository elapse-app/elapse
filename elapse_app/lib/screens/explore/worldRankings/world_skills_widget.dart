import 'package:elapse_app/screens/explore/worldRankings/world_skills.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_skills_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../aesthetics/color_pallete.dart';
import '../../../aesthetics/color_schemes.dart';
import '../../../classes/Team/team.dart';
import '../../../classes/Team/vdaStats.dart';

class WorldSkillsWidget extends StatelessWidget {
  const WorldSkillsWidget({
    super.key,
    required this.stats,
    required this.team,
  });

  final VDAStats stats;
  final Team? team;

  @override
  Widget build(BuildContext context) {
    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        worldSkillsPage(
          context, stats.id, stats.teamNum, stats,
          team: team);
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
              child: Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 100,
                    child: Text(
                      stats.teamNum,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40,
                        height: 1,
                        letterSpacing: -1.5,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface
                      )
                    )
                  ),
                  Flexible(
                    flex: 50,
                    fit: FlexFit.tight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rank ${stats.worldSkillsRank}",
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                        Text("${stats.skillsScore} pts",
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 50,
                    fit: FlexFit.tight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${stats.maxDriver}",
                              style: const TextStyle(
                                fontSize: 16,
                              )
                            ),
                            const Icon(Icons.sports_esports_outlined),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${stats.maxAuto}",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            const Icon(Icons.data_object),
                          ],
                        ),
                      ],
                    )
                  )
                ]
              )
            )
          ]
        )
      )
    )
  }
}