import 'dart:convert';

import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills.dart';
import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_rankings_filter.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_rankings_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Team/teamPreview.dart';
import '../../classes/Team/world_skills.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_tab_bar.dart';

class WorldRankingsScreen extends StatefulWidget {
  final int initIndex;
  final Future<List<VDAStats>>? stats;

  const WorldRankingsScreen({super.key, this.initIndex = 0, this.stats});

  @override
  State<WorldRankingsScreen> createState() => _WorldRankingsState();
}

class _WorldRankingsState extends State<WorldRankingsScreen> {
  late Future<List<WorldSkillsStats>> futureSkillsStats;
  late Future<List<VDAStats>> futureVDAStats;
  late List<TeamPreview> savedTeams;
  late bool inTM;

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

  WorldRankingsFilter filter = WorldRankingsFilter();

  int seasonID = 190;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initIndex;

    futureSkillsStats = getWorldSkillsRankings(seasonID);
    futureVDAStats = getTrueSkillData();
    savedTeams = _getSavedTeams();
    inTM = _isInTM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
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
                            transitionDuration:
                                const Duration(milliseconds: 300),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 300),
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                WorldRankingsSearchScreen(
                                    skills: futureSkillsStats,
                                    vda: futureVDAStats),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
            ),
            backNavigation: true,
          ),
          CustomTabBar(
            tabs: pageTitles,
            onPressed: (int v) {
              setState(() {
                selectedIndex = v;
              });
            },
            initIndex: widget.initIndex,
          ),
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  label: Text(skillsSort[index]),
                                  selected: sortIndex == index,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1.5),
                                      borderRadius: BorderRadius.circular(10)),
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  chipAnimationStyle: ChipAnimationStyle(
                                      enableAnimation: AnimationStyle(
                                          duration: Duration.zero),
                                      selectAnimation: AnimationStyle(
                                          duration: Duration.zero)),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      sortIndex = index;
                                    });
                                  },
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
                                      onPressed: () async {
                                        WorldRankingsFilter updatedFilter =
                                            await worldRankingsFilter(
                                                context,
                                                filter,
                                                inTM,
                                                futureSkillsStats,
                                                futureVDAStats);
                                        setState(() {
                                          filter = updatedFilter;
                                        });
                                      })
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      label: Text(tsSort[index]),
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      selected: sortIndex == index,
                                      selectedColor:
                                          Theme.of(context).colorScheme.primary,
                                      chipAnimationStyle: ChipAnimationStyle(
                                          enableAnimation: AnimationStyle(
                                              duration: Duration.zero),
                                          selectAnimation: AnimationStyle(
                                              duration: Duration.zero)),
                                      onSelected: (bool selected) {
                                        setState(() {
                                          sortIndex = index;
                                        });
                                      },
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
                                          onPressed: () async {
                                            WorldRankingsFilter updatedFilter =
                                                await worldRankingsFilter(
                                                    context,
                                                    filter,
                                                    inTM,
                                                    futureSkillsStats,
                                                    futureVDAStats);
                                            setState(() {
                                              filter = updatedFilter;
                                            });
                                          })
                                    ]))
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(),
          FutureBuilder(
              future: Future.wait([futureSkillsStats, futureVDAStats]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> pages = [
                    WorldSkillsPage(
                        rankings: snapshot.data![0] as List<WorldSkillsStats>,
                        sort: sortIndex,
                        filter: filter,
                        savedTeams: savedTeams),
                    WorldTrueSkillPage(
                        stats: snapshot.data![1] as List<VDAStats>,
                        sort: sortIndex,
                        filter: filter,
                        savedTeams: savedTeams),
                  ];
                  return pages[selectedIndex];
                }
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                      child: Center(
                    child: Text("Failed to load world rankings"),
                  ));
                } else {
                  return const SliverToBoxAdapter(
                    child: LinearProgressIndicator(),
                  );
                }
              })
        ],
      ),
    );
  }

  List<TeamPreview> _getSavedTeams() {
    final String savedTeam = prefs.getString("savedTeam") ?? "";
    TeamPreview savedTeamPreview = TeamPreview(
        teamID: jsonDecode(savedTeam)["teamID"],
        teamNumber: jsonDecode(savedTeam)["teamNumber"]);
    List<String> savedTeamsString = prefs.getStringList("savedTeams") ?? [];

    List<TeamPreview> savedTeams = [];
    savedTeams.add(savedTeamPreview);
    savedTeams.addAll(savedTeamsString
        .map((e) => TeamPreview(
            teamID: jsonDecode(e)["teamID"],
            teamNumber: jsonDecode(e)["teamNumber"]))
        .toList());
    return savedTeams;
  }

  bool _isInTM() {
    return prefs.getBool("isTournamentMode") ?? false;
  }
}
