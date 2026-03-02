import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_filter.dart';
import 'package:elapse_app/screens/tournament/pages/skills/skills_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/teamPreview.dart';
import '../../../../main.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage(
      {super.key,
      required this.skills,
      required this.teams,
      required this.divisions,
      this.sort = 0,
      required this.filter});

  final Map<int, TournamentSkills> skills;
  final List<Team> teams;
  final List<Division> divisions;
  final int sort;
  final TournamentRankingsFilter filter;

  @override
  Widget build(BuildContext context) {
    List<Team> filteredTeams = teams
        .where((e) => skills[e.id] != null && skills[e.id]!.rank != 0)
        .toList();

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
      filteredTeams = filteredTeams.where((element) => savedTeams.any((element2) => element2.teamID == element.id)).toList();
    }

    List<TeamPreview> scoutedTeams = [];
    if (filter.scouted) {
      filteredTeams = filteredTeams.where((e) => scoutedTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    List<TeamPreview> pickListTeams = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
    if (filter.onPicklist) {
      filteredTeams = filteredTeams.where((e) => pickListTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    if (filteredTeams.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(
            icon: Icons.sports_esports_outlined,
            message: "Skills not available"),
      );
    }

    if (sort == 0) {
      filteredTeams.sort((a, b) {
        return skills[a.id]!.rank.compareTo(skills[b.id]!.rank);
      });
    } else if (sort == 1) {
      filteredTeams.sort((a, b) {
        if (skills[b.id]!.driverScore == skills[a.id]!.driverScore) {
          return skills[a.id]!.rank.compareTo(skills[b.id]!.rank);
        }
        return skills[b.id]!.driverScore.compareTo(skills[a.id]!.driverScore);
      });
    } else if (sort == 2) {
      filteredTeams.sort((a, b) {
        if (skills[b.id]!.autonScore == skills[a.id]!.autonScore) {
          return skills[a.id]!.rank.compareTo(skills[b.id]!.rank);
        }
        return skills[b.id]!.autonScore.compareTo(skills[a.id]!.autonScore);
      });
    } else if (sort == 3) {
      filteredTeams.sort((a, b) {
        if (skills[b.id]!.driverAttempts == skills[a.id]!.driverAttempts) {
          return skills[a.id]!.rank.compareTo(skills[b.id]!.rank);
        }
        return skills[b.id]!.driverAttempts.compareTo(skills[a.id]!.driverAttempts);
      });
    } else if (sort == 4) {
      filteredTeams.sort((a, b) {
        if (skills[b.id]!.autonAttempts == skills[a.id]!.autonAttempts) {
          return skills[a.id]!.rank.compareTo(skills[b.id]!.rank);
        }
        return skills[b.id]!.autonAttempts.compareTo(skills[a.id]!.autonAttempts);
      });
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return Column(
              children: [
                SkillsWidget(
                  team: filteredTeams[index],
                  stats: skills[filteredTeams[index].id]!,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  height: 3,
                )
              ],
            );
          },
          childCount: filteredTeams.length,
        ),
      ),
    );
  }
}
