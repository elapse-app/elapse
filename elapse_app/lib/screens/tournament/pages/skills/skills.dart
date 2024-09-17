import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/screens/tournament/pages/skills/skills_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/material.dart';

class SkillsPage extends StatelessWidget {
  const SkillsPage(
      {super.key,
      required this.skills,
      required this.teams,
      required this.divisions});

  final Map<int, TournamentSkills> skills;
  final List<Team> teams;
  final List<Division> divisions;

  @override
  Widget build(BuildContext context) {
    List<Team> filteredTeams = teams
        .where((e) => skills[e.id] != null && skills[e.id]!.rank != 0)
        .toList();
    filteredTeams.sort((a, b) {
      return skills[b.id]!.score.compareTo(skills[a.id]!.score);
    });
    if (filteredTeams.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(
            icon: Icons.sports_esports_outlined,
            message: "Skills not available"),
      );
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
                  skills: skills[filteredTeams[index].id]!,
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
