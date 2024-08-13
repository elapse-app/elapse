import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills_widget.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Team/world_skills.dart';
import '../../../widgets/big_error_message.dart';

class WorldSkillsPage extends StatefulWidget {
  Future<List<WorldSkillsStats>>? skillsStats;
  int sort;

  WorldSkillsPage({
    super.key,
    required this.skillsStats,
    required this.sort,
  });

  @override
  State<WorldSkillsPage> createState() => _WorldSkillsState();
}

class _WorldSkillsState extends State<WorldSkillsPage> {
  int seasonID = 190;

  @override
  void initState() {
    super.initState();

    widget.skillsStats = getWorldSkillsRankings(seasonID);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.skillsStats,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: LinearProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return WorldSkillsLoadedPage(
              rankings: snapshot.data as List<WorldSkillsStats>,
              sort: widget.sort);
        } else {
          return const SliverToBoxAdapter(
              child: Center(
            child: Text("Failed to load world rankings"),
          ));
        }
      },
    );
  }
}

class WorldSkillsLoadedPage extends StatelessWidget {
  const WorldSkillsLoadedPage({
    super.key,
    required this.rankings,
    required this.sort,
  });

  final List<WorldSkillsStats> rankings;
  final int sort;

  @override
  Widget build(BuildContext context) {
    List<WorldSkillsStats> teams = rankings.toList();
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

    if (rankings.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(
            icon: Icons.sports_esports_outlined,
            message: "Skills rankings not available"),
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
      childCount: rankings.length,
    ));
  }
}
