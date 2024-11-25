import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_filter.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../../../classes/Team/vdaStats.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../../classes/Tournament/tskills.dart';

class RankingsPage extends StatelessWidget {
  const RankingsPage({
    super.key,
    required this.searchQuery,
    required this.sort,
    required this.divisionIndex,
    required this.filter,
  });

  final String searchQuery;
  final int divisionIndex;
  final String sort;
  final TournamentRankingsFilter filter;

  @override
  Widget build(BuildContext context) {
    Tournament tournament = loadTournament(prefs.getString("recently-opened-tournament"));

    List<Team> teams = tournament.teams;
    List<TeamPreview> savedTeams = [];
    if (filter.saved) {
      final String savedTeam = prefs.getString("savedTeam") ?? "";
      TeamPreview savedTeamPreview =
          TeamPreview(teamID: jsonDecode(savedTeam)["teamID"], teamNumber: jsonDecode(savedTeam)["teamNumber"]);
      List<String> savedTeamsString = prefs.getStringList("savedTeams") ?? [];
      savedTeams.add(savedTeamPreview);
      savedTeams.addAll(savedTeamsString
          .map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"]))
          .toList());
      teams = tournament.teams.where((element) => savedTeams.any((element2) => element2.teamID == element.id)).toList();
    } else {
      teams = tournament.teams;
    }

    List<TeamPreview> scoutedTeams = [];
    if (filter.scouted) {
      teams = tournament.teams.where((e) => scoutedTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    List<TeamPreview> pickListTeams = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
    if (filter.onPicklist) {
      teams = tournament.teams.where((e) => pickListTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    Map<int, TeamStats>? rankings = tournament.divisions[divisionIndex].teamStats;

    if (rankings == null || rankings.isEmpty) {
      return SliverToBoxAdapter(
        child: BigErrorMessage(icon: Icons.format_list_numbered_outlined, message: "Rankings not available"),
      );
    }

    List<Team> divisionTeams = teams.where((e) => rankings[e.id] != null).toList();
    if (sort == "Rank") {
      divisionTeams.sort((a, b) {
        return rankings[a.id]!.rank.compareTo(rankings[b.id]!.rank);
      });
    } else if (sort == "AP") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.ap.compareTo(rankings[a.id]!.ap);
      });
    } else if (sort == "SP") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.sp.compareTo(rankings[a.id]!.sp);
      });
    } else if (sort == "AWP") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.awp.compareTo(rankings[a.id]!.awp);
      });
    } else if (sort == "OPR") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.opr.compareTo(rankings[a.id]!.opr);
      });
    } else if (sort == "DPR") {
      divisionTeams.sort((a, b) {
        return rankings[b.id]!.dpr.compareTo(rankings[a.id]!.dpr) * -1;
      });
    } else if (sort == "CCWM") {
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

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final team = divisionTeams[index];
          final teamStats = rankings[team.id];
          if (teamStats == null) {
            return const SizedBox();
          }

          return Column(
            children: [
              RankingsWidget(
                teamID: team.id,
                teamNumber: team.teamNumber!,
                sort: sort,
                allianceColor: Theme.of(context).colorScheme.onSurface,
              ),
              Divider(
                color: Theme.of(context).colorScheme.surfaceDim,
                height: 3,
              )
            ],
          );
        }, childCount: divisionTeams.length),
      ),
    );
  }
}
