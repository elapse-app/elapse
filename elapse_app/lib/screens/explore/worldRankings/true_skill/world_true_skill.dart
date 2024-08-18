import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill_widget.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/teamPreview.dart';
import '../../../../classes/Team/vdaStats.dart';
import '../../../widgets/big_error_message.dart';
import '../world_rankings_filter.dart';

class WorldTrueSkillPage extends StatefulWidget {
  final Future<List<VDAStats>> vdaStats;
  final int sort;
  final WorldRankingsFilter filter;
  final Future<List<TeamPreview>> savedTeams;

  const WorldTrueSkillPage({
    super.key,
    required this.vdaStats,
    required this.sort,
    required this.filter,
    required this.savedTeams,
  });

  @override
  State<WorldTrueSkillPage> createState() => _WorldTrueSkillState();
}

class _WorldTrueSkillState extends State<WorldTrueSkillPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([widget.vdaStats, widget.savedTeams]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
              child: LinearProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return WorldTrueSkillLoadedPage(
              stats: snapshot.data?[0] as List<VDAStats>,
              sort: widget.sort,
              filter: widget.filter,
              savedTeams: snapshot.data?[1] as List<TeamPreview>,
            );
          } else {
            return const SliverToBoxAdapter(
                child: Center(
              child: Text("Failed to load world rankings"),
            ));
          }
        });
  }
}

class WorldTrueSkillLoadedPage extends StatelessWidget {
  const WorldTrueSkillLoadedPage({
    super.key,
    required this.stats,
    required this.sort,
    required this.filter,
    required this.savedTeams,
  });

  final List<VDAStats> stats;
  final int sort;
  final WorldRankingsFilter filter;
  final List<TeamPreview> savedTeams;

  @override
  Widget build(BuildContext context) {
    List<VDAStats> teams = stats.where((e) => e.trueSkill != null).toList();

    if (filter.regions!.isNotEmpty) {
      teams = teams
          .where((e) => filter.regions!.any((e2) => e2 == (e.eventRegion ?? "")))
          .toList();
    }

    if (filter.saved) {
      teams = teams
          .where((e) => savedTeams.any((e2) => e2.teamID == e.id))
          .toList();
    }

    if (sort == 0) {
      teams.sort((a, b) {
        return a.trueSkillGlobalRank!.compareTo(b.trueSkillGlobalRank!);
      });
    } else if (sort == 1) {
      teams.sort((a, b) {
        return b.opr!.compareTo(a.opr!);
      });
    } else if (sort == 2) {
      teams.sort((a, b) {
        return a.dpr!.compareTo(b.dpr!);
      });
    } else if (sort == 3) {
      teams.sort((a, b) {
        return b.ccwm!.compareTo(a.ccwm!);
      });
    } else if (sort == 4) {
      teams.sort((a, b) {
        return b.winPercent!.compareTo(a.winPercent!);
      });
    }

    if (teams.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(
            icon: Icons.list_outlined, message: "True Skill not available"),
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
                WorldTrueSkillWidget(stats: stats, sort: sort),
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
