import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/material.dart';

class RankingsPage extends StatelessWidget {
  const RankingsPage(
      {super.key,
      required this.rankings,
      required this.teams,
      required this.games,
      required this.searchQuery,
      required this.skills,
      required this.sort});
  final Map<int, TeamStats> rankings;
  final Map<int, TournamentSkills> skills;
  final List<Team> teams;
  final List<Game>? games;
  final String searchQuery;
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

    if (searchQuery.isNotEmpty) {
      divisionTeams = divisionTeams
          .where((e) =>
              e.teamNumber!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              e.teamName!.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    } else {
      divisionTeams = divisionTeams;
    }

    if (rankings.isEmpty) {
      return SliverToBoxAdapter(
        child: BigErrorMessage(
            icon: Icons.format_list_numbered_outlined,
            message: "Rankings not available"),
      );
    }
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
                    teamID: team.id,
                    skills: skills,
                    team: team,
                    allianceColor: Theme.of(context).colorScheme.onSurface),
                Divider(
                  color: Theme.of(context).colorScheme.surfaceDim,
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
                    teamID: team.id,
                    skills: skills,
                    team: team,
                    allianceColor: Theme.of(context).colorScheme.onSurface),
                Divider(
                  color: Theme.of(context).colorScheme.surfaceDim,
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
