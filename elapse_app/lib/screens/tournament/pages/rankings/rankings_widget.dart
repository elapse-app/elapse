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

class StandardRanking extends StatelessWidget {
  const StandardRanking({
    super.key,
    required this.teamID,
    required this.allianceColor,
    required this.teamNumber,
  });
  final String teamNumber;
  final int teamID;
  final Color allianceColor;
  @override
  Widget build(BuildContext context) {
    Tournament tournament =
        loadTournament(prefs.getString("recently-opened-tournament"));

    int divisionIndex = getTeamDivisionIndex(tournament.divisions, teamID);

    Map<int, TeamStats> rankings =
        tournament.divisions[divisionIndex].teamStats!;
    TeamStats teamStats = rankings[teamID]!;
    int rank = teamStats.rank;
    int wins = teamStats.wins;
    int losses = teamStats.losses;
    int ties = teamStats.ties;
    int wp = teamStats.wp;
    int ap = teamStats.ap;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        tournamentStatsPage(context, teamID, teamNumber);
      },
      child: Container(
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 120,
              fit: FlexFit.tight,
              child: Text(teamNumber,
                  style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w400,
                      color: allianceColor)),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rank $rank",
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text("$wins-$losses-$ties",
                      style: const TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
            Flexible(
              flex: 20,
              fit: FlexFit.tight,
              child: Container(
                  height: 50,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  )),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$wp WP",
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  Text("$ap AP",
                      style: TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OPRRanking extends StatelessWidget {
  const OPRRanking({
    super.key,
    required this.teamID,
    required this.allianceColor,
    required this.teamNumber,
    required this.stat,
  });
  final String teamNumber;
  final int teamID;
  final Color allianceColor;
  final String stat;
  @override
  Widget build(BuildContext context) {
    Tournament tournament =
        loadTournament(prefs.getString("recently-opened-tournament"));

    int divisionIndex = getTeamDivisionIndex(tournament.divisions, teamID);

    Map<int, TeamStats> rankings =
        tournament.divisions[divisionIndex].teamStats!;
    TeamStats teamStats = rankings[teamID]!;
    int rank = teamStats.rank;
    int wins = teamStats.wins;
    int losses = teamStats.losses;
    int ties = teamStats.ties;
    double opr = teamStats.opr;
    double dpr = teamStats.dpr;
    double ccwm = teamStats.ccwm;

    double value = 0;
    if (stat == "OPR") {
      value = opr;
    } else if (stat == "DPR") {
      value = dpr;
    } else if (stat == "CCWM") {
      value = ccwm;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        tournamentStatsPage(context, teamID, teamNumber);
      },
      child: Container(
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 120,
              fit: FlexFit.tight,
              child: Text(teamNumber,
                  style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      letterSpacing: -1.5,
                      fontWeight: FontWeight.w400,
                      color: allianceColor)),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rank $rank",
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text("$wins-$losses-$ties",
                      style: const TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
            Flexible(
              flex: 20,
              fit: FlexFit.tight,
              child: Container(
                  height: 50,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  )),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(stat,
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  Text("$value",
                      style: TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyRanking extends StatelessWidget {
  const EmptyRanking(
      {super.key,
      required this.teamName,
      required this.teamID,
      required this.allianceColor});

  final String teamName;
  final int teamID;
  final Color allianceColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamScreen(
              teamID: teamID,
              teamName: teamName,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: 72,
        child: Text(
          teamName,
          style: TextStyle(
              fontSize: 40,
              height: 1,
              fontWeight: FontWeight.w400,
              color: allianceColor),
        ),
      ),
    );
  }
}
