import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:flutter/material.dart';

<<<<<<< HEAD
class SkillsWidget extends StatelessWidget {
  const SkillsWidget({Key? key, required this.team, required this.skills})
      : super(key: key);

  final Team team;
  final TournamentSkills skills;
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 17,
            fit: FlexFit.tight,
            child: Text(team.teamNumber!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 40,
                    height: 1,
                    letterSpacing: -1.5,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Text(
              skills.rank.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
                height: 50,
                child: VerticalDivider(
                  thickness: 1,
                  color: Theme.of(context).colorScheme.surfaceDim,
                )),
          ),
          Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: Text(skills.score.toString(),
                maxLines: 1,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
          Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AU: ${skills.autonAttempts}"),
                Text(skills.autonScore.toString())
              ],
            ),
          ),
          Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("DC: ${skills.driverAttempts}"),
                Text(skills.driverScore.toString())
              ],
            ),
          ),
        ],
      ),
=======
import '../rankings/tournament_stats_page.dart';

class SkillsWidget extends StatelessWidget {
  const SkillsWidget({Key? key, required this.team, required this.stats}) : super(key: key);

  final Team team;
  final TournamentSkills stats;
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => tournamentStatsPage(context, team.id, team.teamNumber!, team.teamName!),
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
                          flex: 30,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(team.teamNumber!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 32,
                                        height: 1,
                                        letterSpacing: -1.5,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).colorScheme.onSurface)),
                                Text(team.teamName!,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      overflow: TextOverflow.fade,
                                    ))
                              ])),
                      const Spacer(flex: 5),
                      Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Rank ${stats.rank}",
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                            Text("${stats.score} pts",
                                style: const TextStyle(
                                  fontSize: 16,
                                )),
                          ],
                        ),
                      ),
                      Flexible(
                          flex: 5,
                          fit: FlexFit.tight,
                          child: SizedBox(
                            height: 50,
                            child: VerticalDivider(
                              thickness: 0.5,
                              color: Theme.of(context).colorScheme.surfaceDim,
                            ),
                          )),
                      Flexible(
                        flex: 17,
                        fit: FlexFit.tight,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${stats.driverScore}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(Icons.sports_esports_outlined),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("${stats.driverAttempts}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${stats.autonScore}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      )),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(Icons.data_object),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text("${stats.autonAttempts}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      )),
                                ],
                              ),
                            ]),
                      )
                    ]))
              ])),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
    );
  }
}
