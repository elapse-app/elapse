import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills_widget.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/teamPreview.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../../classes/Tournament/tournament.dart';
import '../../../widgets/big_error_message.dart';
import '../world_rankings_filter.dart';

class WorldSkillsPage extends StatelessWidget {
  const WorldSkillsPage({
    super.key,
    required this.rankings,
    required this.sort,
    required this.filter,
    required this.savedTeams,
    required this.pickListTeams,
    required this.tournament,
    required this.scoutedTeams,
  });

  final List<WorldSkillsStats> rankings;
  final int sort;
  final WorldRankingsFilter filter;
  final List<TeamPreview> savedTeams;
  final List<TeamPreview>? pickListTeams;
  final Tournament? tournament;
  final List<TeamPreview> scoutedTeams;

  @override
  Widget build(BuildContext context) {
    List<WorldSkillsStats> teams = rankings.toList();

    if (filter.regions!.isNotEmpty) {
      teams = teams
          .where((e) =>
              filter.regions!.any((e2) => e2 == (e.eventRegion?.name ?? "")))
          .toList();
    }

    if (filter.saved) {
      teams = teams
          .where((e) => savedTeams.any((e2) => e2.teamID == e.teamId))
          .toList();
    }

    if (filter.onPickList && pickListTeams != null) {
      teams = teams.where((e) => pickListTeams!.any((e2) => e2.teamID == e.teamId)).toList();
    }

    if (filter.atTournament && tournament != null) {
      teams = teams
          .where((e) => tournament!.teams.any((e2) => e2.id == e.teamId))
          .toList();
    }

    if (filter.scouted) {
      teams = teams.where((e) => scoutedTeams.any((e2) => e2.teamID == e.teamId)).toList();
    }

    if (sort == 0) {
      teams.sort((a, b) {
        return a.rank.compareTo(b.rank);
      });
    } else if (sort == 1) {
      teams.sort((a, b) {
        return b.driver.compareTo(a.driver);
      });
    } else if (sort == 2) {
      teams.sort((a, b) {
        return b.auton.compareTo(a.auton);
      });
    } else if (sort == 3) {
      teams.sort((a, b) {
        return b.maxDriver.compareTo(a.maxDriver);
      });
    } else if (sort == 4) {
      teams.sort((a, b) {
        return b.maxAuton.compareTo(a.maxAuton);
      });
    }

    if (teams.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(
            icon: Icons.sports_esports_outlined,
            message: "Skills ranking not available"),
      );
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        final stats = teams[index];
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: Column(
              children: [
                WorldSkillsWidget(stats: stats, sort: sort),
                index != teams.length - 1
                    ? Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )
                    : Container(),
              ],
            ));
      },
      childCount: teams.length,
    ));
  }
}
