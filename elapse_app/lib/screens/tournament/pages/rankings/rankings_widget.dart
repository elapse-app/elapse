import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/tournament_stats_page.dart';
import 'package:flutter/material.dart';

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
