import 'dart:convert';

import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills.dart';
import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_rankings_filter.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_rankings_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Filters/gradeLevel.dart';
import '../../classes/Filters/season.dart';
import '../../classes/Team/teamPreview.dart';
import '../../classes/Team/world_skills.dart';
import '../../classes/Tournament/tournament.dart';
import '../my_team/my_team.dart';
import '../widgets/app_bar.dart';
import '../widgets/big_error_message.dart';
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
  late Future<Tournament?> futureTournament;
  List<Future<dynamic>> futures = [];

  late bool isSkillsLoaded;
  late List<WorldSkillsStats> loadedSkills;
  late bool isVDALoaded;
  late List<VDAStats> loadedVDA;

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

  Season season = seasons[0];
  GradeLevel grade = getGradeLevel(prefs.getString("defaultGrade"));

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initIndex;

    isSkillsLoaded = false;
    isVDALoaded = false;
    futureSkillsStats = getWorldSkillsRankings(
        (grade == gradeLevels["College"] ? season.vexUId! : season.vrcId),
        grade).whenComplete(() => isSkillsLoaded = true);
    futures.add(futureSkillsStats);
    futureVDAStats = getTrueSkillData(season.vrcId).whenComplete(() => isVDALoaded = true);
    futures.add(futureVDAStats);
    savedTeams = _getSavedTeams();
    inTM = prefs.getBool("isTournamentMode") ?? false;

    int? tournamentId = prefs.getInt("tournamentID");
    if (inTM && tournamentId != null) {
      futureTournament = TMTournamentDetails(tournamentId);
      futures.add(futureTournament);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: Padding(
              padding: const EdgeInsets.only(right: 16.5),
              child: Row(
                children: [
                  const Text(
                    "World Rankings",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  FutureBuilder(
                      future: Future.wait([futureSkillsStats, futureVDAStats]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GestureDetector(
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
                                            skills: snapshot.data![0]
                                                as List<WorldSkillsStats>,
                                            vda: snapshot.data![1]
                                                as List<VDAStats>),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              });
                        }
                        return const Icon(Icons.search);
                      })
                ],
              ),
            ),
            backNavigation: true,
            background: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                  const Spacer(),
                  Row(children: [
                    const Icon(Icons.school),
                    const SizedBox(width: 4),
                    DropdownButton<GradeLevel>(
                      value: grade,
                      items: gradeLevels.values.map((grade) {
                        return DropdownMenuItem(
                          value: grade,
                          child: Text(getGrade(grade.name),
                              overflow: TextOverflow.fade,
                              style: const TextStyle(fontSize: 16)),
                        );
                      }).toList(),
                      onChanged: (GradeLevel? value) => {
                        setState(() {
                          grade = value!;
                          isSkillsLoaded = false;
                          futureSkillsStats = getWorldSkillsRankings(
                              grade == gradeLevels["College"]
                                  ? season.vexUId!
                                  : season.vrcId,
                              grade).then((data) {
                                isSkillsLoaded = true;
                                return loadedSkills = data;
                              });
                          futures[0] = futureSkillsStats;
                        })
                      },
                    ),
                  ]),
                  const SizedBox(width: 15),
                  GestureDetector(
                      onTap: () async {
                        Season updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeasonFilterPage(
                                selected: season,
                                seasonsList: seasons.sublist(
                                    0,
                                    seasons.indexWhere((e) => e.vrcId == 115) +
                                        1)),
                          ),
                        );
                        setState(() {
                          season = updated;
                          isSkillsLoaded = false;
                          futureSkillsStats = getWorldSkillsRankings(
                              grade == gradeLevels["College"]
                                  ? season.vexUId!
                                  : season.vrcId,
                              grade).then((data) {
                            isSkillsLoaded = true;
                            return loadedSkills = data;
                          });
                          isVDALoaded = false;
                          futureVDAStats = getTrueSkillData(season.vrcId).then((data) {
                            isVDALoaded = true;
                            return loadedVDA = data;
                          });
                          futures[0] = futureSkillsStats;
                          futures[1] = futureVDAStats;
                        });
                      },
                      child: Row(children: [
                        const Icon(Icons.event_note),
                        const SizedBox(width: 4),
                        Text(
                          season.name.substring(10),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.arrow_right)
                      ]))
                ],
              ),
            ),
          ),
          CustomTabBar(
            tabs: pageTitles,
            onPressed: (int v) {
              setState(() {
                selectedIndex = v;
                sortIndex = 0;
              });
            },
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
                          child: Stack(
                            children: [
                              ListView(
                                scrollDirection: Axis.horizontal,
                                children: List<Widget>.generate(5, (int index) {
                                  return Container(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: ChoiceChip(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      label: Text(skillsSort[index],
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          )),
                                      selected: sortIndex == index,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                              IgnorePointer(
                                ignoring: true,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withOpacity(0),
                                        Theme.of(context).colorScheme.surface,
                                      ],
                                      stops: const [0.9, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FutureBuilder(
                                future: Future.wait(
                                    [futureSkillsStats, futureVDAStats]),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return IconButton(
                                        icon: const Icon(
                                          Icons.filter_list,
                                          size: 30,
                                        ),
                                        onPressed: () async {
                                          var skills = snapshot.data![0]
                                              as List<WorldSkillsStats>;
                                          var vda = snapshot.data![1]
                                              as List<VDAStats>;
                                          List<String> regions = skills
                                              .map((e) => e.eventRegion!.name)
                                              .toList();
                                          regions.addAll(
                                              vda.map((e) => e.eventRegion!));
                                          regions = regions.toSet().toList();
                                          regions.sort();

                                          WorldRankingsFilter updatedFilter =
                                              await worldRankingsFilter(context,
                                                  filter, inTM, regions);
                                          setState(() {
                                            filter = updatedFilter;
                                          });
                                        });
                                  }
                                  return IconButton(
                                      icon: const Icon(
                                        Icons.filter_list,
                                        size: 30,
                                      ),
                                      onPressed: () {});
                                },
                              )
                            ],
                          ),
                        ),
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
                              child: Stack(
                                children: [
                                  ListView(
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        List<Widget>.generate(5, (int index) {
                                      return Container(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: ChoiceChip(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5),
                                          label: Text(tsSort[index],
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              )),
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          selected: sortIndex == index,
                                          selectedColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          chipAnimationStyle:
                                              ChipAnimationStyle(
                                                  enableAnimation:
                                                      AnimationStyle(
                                                          duration:
                                                              Duration.zero),
                                                  selectAnimation:
                                                      AnimationStyle(
                                                          duration:
                                                              Duration.zero)),
                                          onSelected: (bool selected) {
                                            setState(() {
                                              sortIndex = index;
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  IgnorePointer(
                                    ignoring: true,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .surface
                                                .withOpacity(0),
                                            Theme.of(context)
                                                .colorScheme
                                                .surface,
                                          ],
                                          stops: const [
                                            0.9,
                                            1.0,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      FutureBuilder(
                                        future: Future.wait([
                                          futureSkillsStats,
                                          futureVDAStats
                                        ]),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return IconButton(
                                                icon: const Icon(
                                                  Icons.filter_list,
                                                  size: 30,
                                                ),
                                                onPressed: () async {
                                                  var skills = snapshot.data![0]
                                                      as List<WorldSkillsStats>;
                                                  var vda = snapshot.data![1]
                                                      as List<VDAStats>;
                                                  List<String> regions = skills
                                                      .map((e) =>
                                                          e.eventRegion!.name)
                                                      .toList();
                                                  regions.addAll(vda.map(
                                                      (e) => e.eventRegion!));
                                                  regions =
                                                      regions.toSet().toList();
                                                  regions.sort();

                                                  WorldRankingsFilter
                                                      updatedFilter =
                                                      await worldRankingsFilter(
                                                          context,
                                                          filter,
                                                          inTM,
                                                          regions);
                                                  setState(() {
                                                    filter = updatedFilter;
                                                  });
                                                });
                                          }
                                          return IconButton(
                                              icon: const Icon(
                                                Icons.filter_list,
                                                size: 30,
                                              ),
                                              onPressed: () {});
                                        },
                                      )
                                    ]))
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(),
          isSkillsLoaded && isVDALoaded
              ? Builder(builder: (context) {
                  List<Widget> pages = [
                    WorldSkillsPage(
                      rankings: loadedSkills,
                      sort: sortIndex,
                      filter: filter,
                      savedTeams: savedTeams,
                      pickListTeams: const [],
                      tournament: inTM
                          ? loadTournament(prefs.getString("TMSavedTournament"))
                          : null,
                      scoutedTeams: const [],
                    ),
                    WorldTrueSkillPage(
                      stats: loadedVDA,
                      sort: sortIndex,
                      filter: filter,
                      savedTeams: savedTeams,
                      tournament: inTM
                          ? loadTournament(prefs.getString("TMSavedTournament"))
                          : null,
                    ),
                  ];
                  return pages[selectedIndex];
                })
              : FutureBuilder(
                  future: Future.wait(futures),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return const SliverToBoxAdapter(
                          child: LinearProgressIndicator(),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          print(snapshot.error);
                          return const SliverToBoxAdapter(
                              child: BigErrorMessage(
                            icon: Icons.list,
                            message: "Failed to load world rankings",
                          ));
                        }

                        loadedSkills = snapshot.data![0] as List<WorldSkillsStats>;
                        loadedVDA = snapshot.data![1] as List<VDAStats>;

                        List<Widget> pages = [
                          WorldSkillsPage(
                            rankings:
                                snapshot.data![0] as List<WorldSkillsStats>,
                            sort: sortIndex,
                            filter: filter,
                            savedTeams: savedTeams,
                            pickListTeams: const [],
                            tournament:
                                inTM ? snapshot.data![2] as Tournament? : null,
                            scoutedTeams: const [],
                          ),
                          WorldTrueSkillPage(
                            stats: snapshot.data![1] as List<VDAStats>,
                            sort: sortIndex,
                            filter: filter,
                            savedTeams: savedTeams,
                            tournament:
                                inTM ? snapshot.data![2] as Tournament? : null,
                          ),
                        ];
                        return pages[selectedIndex];
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
}
