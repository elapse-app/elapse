import 'dart:convert';

import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills.dart';
import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_rankings_filter.dart';
import 'package:elapse_app/screens/explore/worldRankings/world_rankings_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Filters/gradeLevel.dart';
import '../../classes/Filters/season.dart';
import '../../classes/Team/teamPreview.dart';
import '../../classes/Team/vexDexStats.dart';
import '../../classes/Team/world_skills.dart';
import '../../classes/Tournament/tournament.dart';
import '../my_team/my_team.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_tab_bar.dart';

class WorldRankingsScreen extends StatefulWidget {
  final int initIndex;

  const WorldRankingsScreen({super.key, this.initIndex = 0});

  @override
  State<WorldRankingsScreen> createState() => _WorldRankingsState();
}

class _WorldRankingsState extends State<WorldRankingsScreen> {
  late Future<List<WorldSkillsStats>> futureSkillsStats;
  late List<TeamPreview> savedTeams;
  late List<TeamPreview> picklistTeams;
  late bool inTM;
  List<Future<dynamic>> futures = [];

  late bool isSkillsLoaded;
  List<WorldSkillsStats>? loadedSkills;
  Tournament? _tournament;

  late Future<List<VexDexStats>> futureVexDexStats;
  bool isTrueSkillLoaded = false;
  List<VexDexStats>? loadedVexDex;

  int selectedIndex = 0;
  List<String> pageTitles = ["Skills", "TrueSkill"];

  int sortIndex = 0;
  List<String> skillsSort = ["Total", "Driver", "Auton", "Highest Driver", "Highest Auton"];
  List<String> trueSkillSort = ["TrueSkill", "OPR", "DPR", "CCWM", "Win %"];

  double _fadeStart = 0, _fadeEnd = 1;

  WorldRankingsFilter filter = WorldRankingsFilter();

  Season season = seasons[0];
  GradeLevel grade = getGradeLevel(prefs.getString("defaultGrade"));

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initIndex.clamp(0, pageTitles.length - 1);

    futures = [Future.value(), Future.value()];
    _loadSkills();
    _loadTrueSkill();

    savedTeams = _getSavedTeams();
    picklistTeams = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
    inTM = prefs.getBool("isTournamentMode") ?? false;
    _loadTournament();
  }

  // Incremented on every (re)load. A response is applied only if its id is
  // still the latest, so a slow request for a previously selected season or
  // grade can't land after a newer one and overwrite its results.
  int _skillsRequestId = 0;
  int _trueSkillRequestId = 0;

  /// (Re)fetches world skills for the current [season] and [grade]. Does not
  /// call setState itself for the reset, so callers inside setState are fine.
  void _loadSkills() {
    final requestId = ++_skillsRequestId;
    isSkillsLoaded = false;
    loadedSkills = null;
    futureSkillsStats =
        getWorldSkillsRankings(grade == gradeLevels["College"] ? season.vexUId! : season.vrcId, grade).then((data) {
      if (mounted && requestId == _skillsRequestId) {
        setState(() {
          isSkillsLoaded = true;
          loadedSkills = data;
        });
      }
      return data;
    });
    futures[0] = futureSkillsStats;
  }

  /// (Re)loads the whole TrueSkill leaderboard for the current [season].
  /// VexDex only has VRC data (no VEX U season), so this always uses the VRC
  /// season id; the grade filter is applied client-side in [_trueSkillForGrade].
  ///
  /// Stale-while-revalidate: any cached copy (memory/disk) is shown at once,
  /// then [getAllVexDexTeams] revalidates it with one conditional request (ETag)
  /// and re-downloads only when the data actually changed.
  void _loadTrueSkill() {
    final requestId = ++_trueSkillRequestId;
    isTrueSkillLoaded = false;
    loadedVexDex = null;
    final seasonId = season.vrcId;

    void apply(List<VexDexStats> data) {
      if (!mounted || requestId != _trueSkillRequestId || identical(data, loadedVexDex)) return;
      setState(() {
        isTrueSkillLoaded = true;
        loadedVexDex = data;
      });
    }

    getCachedVexDexTeams(seasonId).then((cached) {
      // Don't let a slow disk read overwrite fresher network data.
      if (cached != null && loadedVexDex == null) apply(cached);
    });
    futureVexDexStats = getAllVexDexTeams(seasonId).then((data) {
      apply(data);
      return data;
    });
    futures[1] = futureVexDexStats;
  }

  /// TrueSkill rankings for the selected grade only. Empty for College since
  /// VexDex has no VEX U data, which the page shows as "not available".
  List<VexDexStats> get _trueSkillForGrade => (loadedVexDex ?? []).where((e) => e.gradeLevel == grade).toList();

  Future<void> _loadTournament() async {
    if (inTM) {
      final tournamentId = prefs.getInt("tournamentID");
      if (tournamentId != null && tournamentId != 0) {
        final tournament = await getTournamentFromCache(tournamentId);
        if (mounted) {
          setState(() {
            _tournament = tournament;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: const Text(
              "Rankings",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            backNavigation: true,
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23.0, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
                                    overflow: TextOverflow.fade, style: const TextStyle(fontSize: 16)),
                              );
                            }).toList(),
                            onChanged: (GradeLevel? value) => {
                              setState(() {
                                grade = value!;
                                _loadSkills();
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
                                      seasonsList: seasons.sublist(0, seasons.indexWhere((e) => e.vrcId == 115) + 1)),
                                ),
                              );
                              if (!mounted) return;
                              setState(() {
                                season = updated;
                                _loadSkills();
                                _loadTrueSkill();
                              });
                            },
                            child: Row(children: [
                              const Icon(Icons.event_note),
                              const SizedBox(width: 4),
                              Text(
                                season.name.length > 10 ? season.name.substring(10) : season.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Icon(Icons.arrow_right)
                            ])),
                        const SizedBox(width: 8),
                        (selectedIndex == 0 ? isSkillsLoaded : isTrueSkillLoaded)
                            ? IconButton(
                                icon: const Icon(
                                  Icons.search,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      transitionDuration: const Duration(milliseconds: 300),
                                      reverseTransitionDuration: const Duration(milliseconds: 300),
                                      pageBuilder: (context, animation, secondaryAnimation) => selectedIndex == 0
                                          ? WorldRankingsSearchScreen(skills: loadedSkills!)
                                          : WorldRankingsSearchScreen(trueSkill: _trueSkillForGrade),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                })
                            : const Icon(Icons.search)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomTabBar(
            tabs: pageTitles,
            disabledTabs: [!isSkillsLoaded, !isTrueSkillLoaded],
            onPressed: (int v) {
              setState(() {
                selectedIndex = v;
                sortIndex = 0;
                _fadeStart = 0;
                _fadeEnd = 1;
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
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              setState(() {
                                _fadeStart = scrollNotification.metrics.pixels / 10;
                                _fadeEnd =
                                    (scrollNotification.metrics.maxScrollExtent - scrollNotification.metrics.pixels) /
                                        10;

                                _fadeStart = _fadeStart.clamp(0.0, 1.0);
                                _fadeEnd = _fadeEnd.clamp(0.0, 1.0);
                              });
                              return true;
                            },
                            child: Stack(
                              children: [
                                ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List<Widget>.generate(5, (int index) {
                                    return Container(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: ChoiceChip(
                                        padding: const EdgeInsets.symmetric(horizontal: 5),
                                        label: Text(skillsSort[index],
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                            )),
                                        selected: sortIndex == index,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                                            borderRadius: BorderRadius.circular(10)),
                                        selectedColor: Theme.of(context).colorScheme.primary,
                                        chipAnimationStyle: ChipAnimationStyle(
                                            enableAnimation: AnimationStyle(duration: Duration.zero),
                                            selectAnimation: AnimationStyle(duration: Duration.zero)),
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
                                          Theme.of(context).colorScheme.surface,
                                          Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                                          Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                                          Theme.of(context).colorScheme.surface,
                                        ],
                                        stops: [0, 0.05 * _fadeStart, 1 - 0.05 * _fadeEnd, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              FutureBuilder(
                                future: futureSkillsStats,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return IconButton(
                                        icon: const Icon(
                                          Icons.filter_list,
                                          size: 30,
                                        ),
                                        onPressed: () async {
                                          var skills = snapshot.data as List<WorldSkillsStats>;
                                          List<String> regions = skills.map((e) => e.eventRegion!.name).toList();
                                          regions = regions.toSet().toList();
                                          regions.sort();

                                          WorldRankingsFilter updatedFilter =
                                              await worldRankingsFilter(context, filter, inTM, regions);
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
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  setState(() {
                                    _fadeStart = scrollNotification.metrics.pixels / 10;
                                    _fadeEnd = (scrollNotification.metrics.maxScrollExtent -
                                            scrollNotification.metrics.pixels) /
                                        10;

                                    _fadeStart = _fadeStart.clamp(0.0, 1.0);
                                    _fadeEnd = _fadeEnd.clamp(0.0, 1.0);
                                  });
                                  return true;
                                },
                                child: Stack(
                                  children: [
                                    ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: List<Widget>.generate(trueSkillSort.length, (int index) {
                                        return Container(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: ChoiceChip(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            label: Text(trueSkillSort[index],
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSurface,
                                                )),
                                            selected: sortIndex == index,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: Theme.of(context).colorScheme.primary, width: 1.5),
                                                borderRadius: BorderRadius.circular(10)),
                                            selectedColor: Theme.of(context).colorScheme.primary,
                                            chipAnimationStyle: ChipAnimationStyle(
                                                enableAnimation: AnimationStyle(duration: Duration.zero),
                                                selectAnimation: AnimationStyle(duration: Duration.zero)),
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
                                              Theme.of(context).colorScheme.surface,
                                              Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                                              Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                                              Theme.of(context).colorScheme.surface,
                                            ],
                                            stops: [0, 0.05 * _fadeStart, 1 - 0.05 * _fadeEnd, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  isTrueSkillLoaded
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.filter_list,
                                            size: 30,
                                          ),
                                          onPressed: () async {
                                            List<String> regions =
                                                _trueSkillForGrade.map((e) => e.region ?? "").toList();
                                            regions = regions.toSet().toList();
                                            regions.sort();

                                            WorldRankingsFilter updatedFilter =
                                                await worldRankingsFilter(context, filter, inTM, regions);
                                            setState(() {
                                              filter = updatedFilter;
                                            });
                                          })
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.filter_list,
                                            size: 30,
                                          ),
                                          onPressed: () {}),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(),
          Builder(builder: (context) {
            List<Widget> pages = [
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            ];
            if (loadedSkills != null) {
              pages[0] = WorldSkillsPage(
                rankings: loadedSkills!,
                sort: sortIndex,
                filter: filter,
                savedTeams: savedTeams,
                picklistTeams: picklistTeams,
                tournament: inTM ? _tournament : null,
                scoutedTeams: const [],
              );
            }
            if (loadedVexDex != null) {
              pages[1] = WorldTrueSkillPage(
                stats: _trueSkillForGrade,
                sort: sortIndex,
                filter: filter,
                savedTeams: savedTeams,
                picklistTeams: picklistTeams,
                tournament: inTM ? _tournament : null,
              );
            }

            return pages[selectedIndex];
          })
        ],
      ),
    );
  }

  List<TeamPreview> _getSavedTeams() {
    final String savedTeam = prefs.getString("savedTeam") ?? "";
    TeamPreview savedTeamPreview =
        TeamPreview(teamID: jsonDecode(savedTeam)["teamID"], teamNumber: jsonDecode(savedTeam)["teamNumber"]);
    List<String> savedTeamsString = prefs.getStringList("savedTeams") ?? [];

    List<TeamPreview> savedTeams = [];
    savedTeams.add(savedTeamPreview);
    savedTeams.addAll(savedTeamsString
        .map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"]))
        .toList());
    return savedTeams;
  }
}
