import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/team_widget.dart';
import 'package:flutter/material.dart';

import '../../../widgets/app_bar.dart';

class AllTeams extends StatelessWidget {
  const AllTeams({super.key, required this.teams});
  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: Row(children: [
              const Text("All Teams", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
              const Spacer(),
              Text("${teams.length}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              const SizedBox(width: 23),
            ]),
            backNavigation: true,
          ),
          RoundedTop(),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: [
                      TeamWidget(
                        teamNumber: teams[index].teamNumber!,
                        teamID: teams[index].id,
                        location: teams[index].location,
                        teamName: teams[index].teamName,
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.surfaceDim,
                        height: 3,
                      )
                    ],
                  );
                },
                childCount: teams.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
