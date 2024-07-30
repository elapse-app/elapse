import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:flutter/material.dart';

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
    );
  }
}
