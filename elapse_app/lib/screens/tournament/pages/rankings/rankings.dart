import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:flutter/material.dart';

class RankingsPage extends StatelessWidget {
  const RankingsPage(
      {super.key,
      required this.rankings,
      required this.teams,
      required this.games,
      required this.sort});
  final Map<int, TeamStats> rankings;
  final List<Team> teams;
  final List<Game>? games;
  final String sort;
  @override
  Widget build(BuildContext context) {
    List<Team> divisionTeams =
        teams.where((e) => rankings[e.id] != null).toList();
    if (sort == "rank") {
      divisionTeams.sort((a, b) {
        return rankings[a.id]!.rank.compareTo(rankings[b.id]!.rank);
      });
    } else if (sort == "ap") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.ap.compareTo(rankings[a.id]!.ap);
      });
    } else if (sort == "opr") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.opr.compareTo(rankings[a.id]!.opr);
      });
    } else if (sort == "dpr") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.dpr.compareTo(rankings[a.id]!.dpr) * -1;
      });
    } else if (sort == "sp") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.sp.compareTo(rankings[a.id]!.sp);
      });
    } else if (sort == "ccwm") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.ccwm.compareTo(rankings[a.id]!.ccwm);
      });
    }

    Color dividerColor =
        Theme.of(context).colorScheme.brightness == Brightness.dark
            ? const Color.fromARGB(255, 55, 55, 55)
            : const Color.fromARGB(255, 211, 211, 211);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final team = divisionTeams[index];
          final teamStats = rankings[team.id];
          if (teamStats == null) {
            return const SizedBox();
          }
          if (sort == "opr" || sort == "dpr" || sort == "ccwm") {
            return Column(
              children: [
                OPRRanking(
                    teamName: team.teamNumber!,
                    stat: sort.toUpperCase(),
                    rankings: rankings,
                    teamStats: teamStats,
                    games: games,
                    allianceColor: Theme.of(context).colorScheme.onSurface),
                Divider(
                  color: dividerColor,
                  height: 3,
                )
              ],
            );
          } else {
            return Column(
              children: [
                StandardRanking(
                    teamName: team.teamNumber!,
                    rankings: rankings,
                    teamStats: teamStats,
                    games: games,
                    allianceColor: Theme.of(context).colorScheme.onSurface),
                Divider(
                  color: dividerColor,
                  height: 3,
                )
              ],
            );
          }
        }, childCount: divisionTeams.length),
      ),
    );
  }
}
