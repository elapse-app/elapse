import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/tournament_stats_page.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/vdaStats.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../../classes/Tournament/tskills.dart';

class RankingsWidget extends StatelessWidget {
  const RankingsWidget({
    super.key,
    required this.teamID,
    required this.teamNumber,
    required this.allianceColor,
    required this.sort,
    this.skills,
    this.worldSkills,
    this.vda,
  });

  final int teamID;
  final String teamNumber;
  final Color allianceColor;
  final String sort;
  final TournamentSkills? skills;
  final WorldSkillsStats? worldSkills;
  final VDAStats? vda;

  @override
  Widget build(BuildContext context) {
    Tournament tournament = loadTournament(prefs.getString("recently-opened-tournament"));

    int divisionIndex = getTeamDivisionIndex(tournament.divisions, teamID);

    Map<int, TeamStats> rankings = tournament.divisions[divisionIndex].teamStats!;
    TeamStats stats = rankings[teamID]!;

    String val1 = "${stats.wins}-${stats.losses}-${stats.ties}", val2 = "${stats.wp} WP", val3 = "${stats.ap} AP", val4 = "${stats.sp} SP";
    switch (sort) {
      case "Rank":
      case "AP":
      case "SP":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = "${stats.ap} AP";
        val4 = "${stats.sp} SP";
        break;
      case "AWP":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.ap} AP";
        val3 = "${stats.awp} AWP";
        val4 = "${stats.awpRate * 100} %";
        break;
      case "OPR":
      case "DPR":
      case "CCWM":
        val1 = "${stats.opr.toStringAsFixed(1)} OPR";
        val2 = "${stats.dpr.toStringAsFixed(1)} DPR";
        val3 = stats.ccwm.toStringAsFixed(1);
        val4 = "CCWM";
        break;
      case "Skills":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = skills != null ? "Rank ${skills?.rank}" : "N/A";
        val4 = skills != null ? "${skills?.score} pts" : "N/A";
        break;
      case "World Skills":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = worldSkills != null ? "Rank ${worldSkills?.rank}" : "N/A";
        val4 = worldSkills != null ? "${worldSkills?.score} pts" : "N/A";
        break;
      case "TrueSkill":
        val1 = "${stats.wins}-${stats.losses}-${stats.ties}";
        val2 = "${stats.wp} WP";
        val3 = vda != null ? "Rank ${vda?.trueSkillGlobalRank}" : "N/A";
        val4 = vda != null ? "${vda?.trueSkill}" : "N/A";
        break;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => tournamentStatsPage(context, teamID, teamNumber),
      child: SizedBox(
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 42,
              fit: FlexFit.tight,
              child: Text("${stats.rank}",
                maxLines: 1,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: allianceColor
                )
              ),
            ),
            Flexible(
              flex: 100,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teamNumber,
                      style: TextStyle(
                          fontSize: 40,
                          height: 1,
                          letterSpacing: -1.5,
                          fontWeight: FontWeight.w400,
                          color: allianceColor)),
                ]
              ),
            ),
            Flexible(
              flex: 42,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(val1,
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text(val2,
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: SizedBox(
                  height: 50,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  )),
            ),
            Flexible(
              flex: 42,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(val3,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text(val4,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                ],
              ),
            )
          ]
        )
      )
    );
  }
}