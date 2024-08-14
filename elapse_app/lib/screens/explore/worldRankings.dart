import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills.dart';
import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill.dart';
import 'package:flutter/material.dart';

import '../../classes/Team/world_skills.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_tab_bar.dart';

class WorldRankingsScreen extends StatefulWidget {
  final int initState;
  final Future<List<VDAStats>>? stats;

  const WorldRankingsScreen({super.key, this.initState = 0, this.stats});

  @override
  State<WorldRankingsScreen> createState() => _WorldRankingsState();
}

class _WorldRankingsState extends State<WorldRankingsScreen> {
  Future<List<VDAStats>>? vdaStats;
  Future<List<WorldSkillsStats>>? skillsStats;

  int selectedIndex = 0;
  List<String> pageTitles = ["Skills", "TrueSkill"];

  int sortIndex = 0;
  List<String> skillsSort = [
    "Total",
    "Driver",
    "Auton",
    "Highest Driver",
    "Highest Auton"
  ];
  List<String> tsSort = ["Score", "OPR", "DPR", "CCWM", "Win %"];

  int seasonID = 190;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initState;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      WorldSkillsPage(skillsStats: skillsStats, sort: sortIndex),
      WorldTrueSkillPage(vdaStats: vdaStats, sort: sortIndex),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: Row(
              children: [
                const Text(
                  "World Rankings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                    child: const Icon(
                      Icons.search,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration: const Duration(milliseconds: 300),
                          pageBuilder: (context, animation, secondaryAnimation) => {},
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    })
              ],
            ),
            backNavigation: true,
          ),
          CustomTabBar(
              tabs: pageTitles,
              onPressed: (int v) {
                setState(() {
                  selectedIndex = v;
                });
              }),
          selectedIndex == 0
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(left: 23),
                    height: 50,
                    child: Flex(
                      direction: Axis.horizontal,
                      children: [
                        Flexible(
                          flex: 6,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List<Widget>.generate(5, (int index) {
                              return Container(
                                padding: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                  label: Text(skillsSort[index]),
                                  selected: sortIndex == index,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      sortIndex = index;
                                    });
                                  },
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        Flexible(
                            flex: 1,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      icon: const Icon(
                                        Icons.filter_list,
                                        size: 30,
                                      ),
                                      onPressed: () {})
                                ]))
                      ],
                    ),
                  ),
                )
              : selectedIndex == 1
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 23),
                        height: 50,
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 6,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: List<Widget>.generate(5, (int index) {
                                  return Container(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: ChoiceChip(
                                      label: Text(tsSort[index]),
                                      selected: sortIndex == index,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          sortIndex = index;
                                        });
                                      },
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                          icon: const Icon(
                                            Icons.filter_list,
                                            size: 30,
                                          ),
                                          onPressed: () {})
                                    ]))
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(),
          pages[selectedIndex],
        ],
      ),
    );
  }
}
