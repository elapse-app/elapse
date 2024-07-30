import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/tournament_stats_page.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class StandardRanking extends StatelessWidget {
  const StandardRanking({
    super.key,
    required this.teamStats,
    required this.rankings,
    required this.teamName,
    required this.skills,
    required this.games,
    this.team,
    required this.teamID,
    required this.allianceColor,
  });
  final Map<int, TeamStats> rankings;
  final String teamName;
  final TeamStats teamStats;
  final List<Game>? games;
  final Map<int, TournamentSkills> skills;
  final Team? team;
  final int teamID;
  final Color allianceColor;
  @override
  Widget build(BuildContext context) {
    int rank = teamStats.rank;
    int wins = teamStats.wins;
    int losses = teamStats.losses;
    int ties = teamStats.ties;
    int wp = teamStats.wp;
    int ap = teamStats.ap;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        tournamentStatsPage(
            context, teamStats, games, rankings, skills, teamName, teamID,
            team: team);
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
              child: Text(teamName,
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
  const OPRRanking(
      {super.key,
      required this.teamStats,
      required this.rankings,
      required this.skills,
      required this.teamName,
      required this.stat,
      required this.games,
      this.team,
      required this.teamID,
      required this.allianceColor});

  final Map<int, TeamStats> rankings;
  final Map<int, TournamentSkills> skills;
  final String stat;
  final String teamName;
  final TeamStats teamStats;
  final List<Game>? games;
  final Team? team;
  final Color allianceColor;
  final int teamID;

  @override
  Widget build(BuildContext context) {
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
        tournamentStatsPage(
          context,
          teamStats,
          games,
          rankings,
          skills,
          teamName,
          teamID,
          team: team,
        );
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
              child: Text(teamName,
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
