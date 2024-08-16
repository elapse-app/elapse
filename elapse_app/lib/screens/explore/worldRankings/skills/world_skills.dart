import 'dart:convert';

import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../classes/Team/teamPreview.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../widgets/big_error_message.dart';
import '../world_rankings_filter.dart';

class WorldSkillsPage extends StatefulWidget {
  final Future<List<WorldSkillsStats>> skillsStats;
  final int sort;
  final WorldRankingsFilter filter;
  final Future<List<TeamPreview>> savedTeams;

  const WorldSkillsPage({
    super.key,
    required this.skillsStats,
    required this.sort,
    required this.filter,
    required this.savedTeams,
  });

  @override
  State<WorldSkillsPage> createState() => _WorldSkillsState();
}

class _WorldSkillsState extends State<WorldSkillsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([widget.skillsStats, widget.savedTeams]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: LinearProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return WorldSkillsLoadedPage(
            rankings: snapshot.data?[0] as List<WorldSkillsStats>,
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
      },
    );
  }
}

class WorldSkillsLoadedPage extends StatelessWidget {
  const WorldSkillsLoadedPage({
    super.key,
    required this.rankings,
    required this.sort,
    required this.filter,
    required this.savedTeams,
  });

  final List<WorldSkillsStats> rankings;
  final int sort;
  final WorldRankingsFilter filter;
  final List<TeamPreview> savedTeams;

  @override
  Widget build(BuildContext context) {
    List<WorldSkillsStats> teams = rankings.toList();

    if (filter.region != "All Regions") {
      teams = teams
          .where((e) => (e.location?.region ?? "") == filter.region)
          .toList();
    }

    if (filter.saved) {
      teams = teams
          .where((e) => savedTeams.any((e2) => e2.teamID == e.teamId))
          .toList();
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
      childCount: teams.length,
    ));
  }
}
