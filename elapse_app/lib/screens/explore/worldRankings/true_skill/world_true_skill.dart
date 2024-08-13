import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill_widget.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/vdaStats.dart';
import '../../../widgets/big_error_message.dart';

class WorldTrueSkillPage extends StatefulWidget {
  Future<List<VDAStats>>? vdaStats;
  int sort;

  WorldTrueSkillPage({
    super.key,
    required this.vdaStats,
    required this.sort,
  });

  @override
  State<WorldTrueSkillPage> createState() => _WorldTrueSkillState();
}

class _WorldTrueSkillState extends State<WorldTrueSkillPage> {
  @override
  void initState() {
    super.initState();

    widget.vdaStats = getTrueSkillData();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.vdaStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SliverToBoxAdapter(
              child: LinearProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return WorldTrueSkillLoadedPage(
                stats: snapshot.data as List<VDAStats>, sort: widget.sort);
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
  });

  final List<VDAStats> stats;
  final int sort;

  @override
  Widget build(BuildContext context) {
    List<VDAStats> teams = stats.where((e) => e.trueSkill != null).toList();
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

    if (stats.isEmpty) {
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
      childCount: stats.length,
    ));
  }
}
