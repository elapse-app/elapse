import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill_widget.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/teamPreview.dart';
import '../../../../classes/Team/vexDexStats.dart';
import '../../../../classes/Tournament/tournament.dart';
import '../../../widgets/big_error_message.dart';
import '../world_rankings_filter.dart';

class WorldTrueSkillPage extends StatelessWidget {
  const WorldTrueSkillPage({
    super.key,
    required this.stats,
    required this.sort,
    required this.filter,
    required this.savedTeams,
    required this.picklistTeams,
    required this.tournament,
  });

  final List<VexDexStats> stats;
  final int sort;
  final WorldRankingsFilter filter;
  final List<TeamPreview> savedTeams;
  final List<TeamPreview> picklistTeams;
  final Tournament? tournament;

  @override
  Widget build(BuildContext context) {
    List<VexDexStats> teams = stats.where((e) => e.matches > 0).toList();

    if (filter.regions!.isNotEmpty) {
      teams = teams.where((e) => filter.regions!.any((e2) => e2 == (e.region ?? ""))).toList();
    }

    if (filter.saved) {
      teams = teams.where((e) => savedTeams.any((e2) => e2.teamID == e.teamId)).toList();
    }

    if (filter.onPicklist && picklistTeams.isNotEmpty) {
      teams = teams.where((e) => picklistTeams.any((e2) => e2.teamID == e.teamId)).toList();
    }

    if (filter.atTournament && tournament != null) {
      teams = teams.where((e) => tournament!.teams.any((e2) => e2.id == e.teamId)).toList();
    }

    if (sort == 0) {
      teams.sort((a, b) {
        return a.trueSkillGlobalRank.compareTo(b.trueSkillGlobalRank);
      });
    } else if (sort == 1) {
      teams.sort((a, b) {
        return b.oprAvg.compareTo(a.oprAvg);
      });
    } else if (sort == 2) {
      teams.sort((a, b) {
        return a.dprAvg.compareTo(b.dprAvg);
      });
    } else if (sort == 3) {
      teams.sort((a, b) {
        return b.ccwmAvg.compareTo(a.ccwmAvg);
      });
    } else if (sort == 4) {
      teams.sort((a, b) {
        return b.winPercent.compareTo(a.winPercent);
      });
    }

    if (teams.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(icon: Icons.list_outlined, message: "TrueSkill ranking not available"),
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
                WorldTrueSkillWidget(stats: stats, rank: index + 1, sort: sort),
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

    // return SliverToBoxAdapter();
  }
}
