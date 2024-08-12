import 'package:elapse_app/screens/explore/worldRankings/world_skills_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../classes/Team/vdaStats.dart';

class WorldSkillsPage extends StatelessWidget {
  const WorldSkillsPage({super.key, required this.rankings});

  final List<VDAStats> rankings;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          (context, index) {
            final stats = rankings[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                children: [
                  WorldSkillsWidget(stats: stats, team: null),
                  index != rankings.length - 1
                    ? Divider(
                      height: 3,
                      color: Theme.of(context).colorScheme.surfaceDim,
                    )
                      : Container(),
                ],
              ));
          }
      )
    );
  }
}