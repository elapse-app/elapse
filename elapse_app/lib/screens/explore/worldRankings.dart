import 'package:elapse_app/screens/explore/worldRankings/world_skills.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_true_skill.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorldRankingsScreen extends StatefulWidget {
  int initState = 0;
  WorldRankingsScreen({super.key, required this.initState});

  @override
  State<WorldRankingsScreen> createState() => _WorldRankingsState();
}

class _WorldRankingsState extends State<WorldRankingsScreen> {
  int selectedIndex = 0;
  List<String> titles = ["World Skills Ranking", "World TrueSkill Ranking"];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initState;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(200),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "World Rankings",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
              ]
            ),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Skills"),
                Tab(text: "TrueSkill"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            WorldSkillsPage(rankings: getTrueSkillData()),
            WorldTrueSkill(),
          ],
        ),
      ),
    );
  }
}
