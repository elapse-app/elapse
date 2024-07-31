import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/team_widget.dart';
import 'package:flutter/material.dart';

class AllTeams extends StatelessWidget {
  const AllTeams({super.key, required this.teams});
  final List<Team> teams;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 125,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: EdgeInsets.only(left: 20, right: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back),
                    ),
                    const Text(
                      "All teams",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
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
