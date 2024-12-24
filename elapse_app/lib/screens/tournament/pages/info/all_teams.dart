import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/team_widget.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import '../../../../classes/Filters/gradeLevel.dart';
import '../../../../classes/Team/teamPreview.dart';
import '../../../../classes/Team/vdaStats.dart';
import '../../../../classes/Team/world_skills.dart';
import '../../../../classes/Tournament/tournament.dart';
import '../../../../main.dart';
import '../../../explore/worldRankings/world_rankings_filter.dart';
import '../../../widgets/app_bar.dart';

class AllTeams extends StatefulWidget {
  const AllTeams({super.key, required this.tournament});

  final Tournament tournament;

  @override
  State<AllTeams> createState() => _AllTeamsState();
}

class _AllTeamsState extends State<AllTeams> {
  int sortIndex = 0;
  List<String> sorts = [
    "Team Number",
    "Team Name",
    "Season OPR",
    "Season DPR",
    "Season CCWM",
    "Season Win %",
    "World Skill",
    "TrueSkill"
  ];
  double _fadeStart = 0, _fadeEnd = 1;

  late Future<List<WorldSkillsStats>> skillsStats;
  List<WorldSkillsStats>? loadedSkills;
  late Future<List<VDAStats>> vdaStats;
  List<VDAStats>? loadedVDA;

  WorldRankingsFilter filter = WorldRankingsFilter();

  late bool inTM;
  late Tournament? tmTournament;
  late List<TeamPreview> savedTeams;
  late List<TeamPreview> picklistTeams;
  late List<TeamPreview> scoutedTeams;

  @override
  void initState() {
    super.initState();

    skillsStats =
        getWorldSkillsRankings(widget.tournament.seasonID, getGradeLevel(prefs.getString("defaultGrade"))).then((data) {
      setState(() {
        loadedSkills = data;
      });
      return data;
    });
    vdaStats = getTrueSkillData(widget.tournament.seasonID).then((data) {
      setState(() {
        loadedVDA = data;
      });
      return data;
    });

    inTM = prefs.getBool("isTournamentMode") ?? false;
    tmTournament = inTM ? loadTournament(prefs.getString("TMSavedTournament")) : null;
    savedTeams = _getSavedTeams();
    picklistTeams = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
    scoutedTeams = [];
  }

  @override
  Widget build(BuildContext context) {
    List<Team> teams = widget.tournament.teams;

    if (filter.regions!.isNotEmpty) {
      teams = teams.where((e) => filter.regions!.any((e2) => e2 == (e.location?.region ?? ""))).toList();
    }
    if (filter.saved) {
      teams = teams.where((e) => savedTeams.any((e2) => e2.teamID == e.id)).toList();
    }
    if (filter.onPicklist && picklistTeams.isNotEmpty) {
      teams = teams.where((e) => picklistTeams.any((e2) => e2.teamID == e.id)).toList();
    }
    if (filter.atTournament && inTM) {
      teams = teams.where((e) => tmTournament!.teams.any((e2) => e2.id == e.id)).toList();
    }
    if (filter.scouted) {
      teams = teams.where((e) => scoutedTeams.any((e2) => e2.teamID == e.id)).toList();
    }

    switch (sortIndex) {
      case 0:
        teams.sort((a, b) {
          num teamNumA = num.parse(a.teamNumber!.substring(0, a.teamNumber!.length - 1));
          num teamNumB = num.parse(b.teamNumber!.substring(0, b.teamNumber!.length - 1));
          if (teamNumA == teamNumB) {
            return a.teamNumber![a.teamNumber!.length - 1].compareTo(b.teamNumber![b.teamNumber!.length - 1]);
          }
          return teamNumA.compareTo(teamNumB);
        });
        break;
      case 1:
        teams.sort((a, b) {
          return a.teamName!.compareTo(b.teamName!);
        });
        break;
      case 2:
        teams.sort((a, b) {
          return (loadedVDA!.singleWhere((e) => e.id == b.id).opr ?? -1e5)
              .compareTo(loadedVDA!.singleWhere((e) => e.id == a.id).opr ?? -1e5);
        });
        break;
      case 3:
        teams.sort((a, b) {
          return (loadedVDA!.singleWhere((e) => e.id == a.id).dpr ?? 1e5)
              .compareTo(loadedVDA!.singleWhere((e) => e.id == b.id).dpr ?? 1e5);
        });
        break;
      case 4:
        teams.sort((a, b) {
          return (loadedVDA!.singleWhere((e) => e.id == b.id).ccwm ?? -1e5)
              .compareTo(loadedVDA!.singleWhere((e) => e.id == a.id).ccwm ?? -1e5);
        });
        break;
      case 5:
        teams.sort((a, b) {
          return (loadedVDA!.singleWhere((e) => e.id == b.id).winPercent ?? -1e5)
              .compareTo(loadedVDA!.singleWhere((e) => e.id == a.id).winPercent ?? -1e5);
        });
        break;
      case 6:
        teams.sort((a, b) {
          return (loadedSkills!.singleWhereOrNull((e) => e.teamId == a.id)?.rank ?? 1e5)
              .compareTo(loadedSkills!.singleWhereOrNull((e) => e.teamId == b.id)?.rank ?? 1e5);
        });
        break;
      case 7:
        teams.sort((a, b) {
          return (loadedVDA!.singleWhere((e) => e.id == b.id).trueSkill ?? 0)
              .compareTo(loadedVDA!.singleWhere((e) => e.id == a.id).trueSkill ?? 0);
        });
        break;
    }

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
          SliverToBoxAdapter(
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
                              (scrollNotification.metrics.maxScrollExtent - scrollNotification.metrics.pixels) / 10;

                          _fadeStart = _fadeStart.clamp(0.0, 1.0);
                          _fadeEnd = _fadeEnd.clamp(0.0, 1.0);
                        });
                        return true;
                      },
                      child: Stack(
                        children: [
                          ListView(
                            scrollDirection: Axis.horizontal,
                            children: List<Widget>.generate(sorts.length, (int index) {
                              if (index >= 2) {
                                return FutureBuilder(
                                    future: index == 6 ? skillsStats : vdaStats,
                                    builder: (context, snapshot) {
                                      return Container(
                                        padding: const EdgeInsets.only(right: 5),
                                        child: ChoiceChip(
                                          padding: const EdgeInsets.symmetric(horizontal: 5),
                                          label: Text(sorts[index],
                                              style: TextStyle(
                                                color: snapshot.connectionState == ConnectionState.done
                                                    ? Theme.of(context).colorScheme.onSurface
                                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                                              )),
                                          selected: sortIndex == index,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: snapshot.connectionState == ConnectionState.done
                                                      ? Theme.of(context).colorScheme.primary
                                                      : Theme.of(context).colorScheme.tertiary,
                                                  width: 1.5),
                                              borderRadius: BorderRadius.circular(10)),
                                          selectedColor: Theme.of(context).colorScheme.primary,
                                          chipAnimationStyle: ChipAnimationStyle(
                                              enableAnimation: AnimationStyle(duration: Duration.zero),
                                              selectAnimation: AnimationStyle(duration: Duration.zero)),
                                          onSelected: snapshot.connectionState == ConnectionState.done
                                              ? (bool selected) {
                                                  setState(() {
                                                    sortIndex = index;
                                                  });
                                                }
                                              : null,
                                        ),
                                      );
                                    });
                              }
                              return Container(
                                padding: const EdgeInsets.only(right: 5),
                                child: ChoiceChip(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  label: Text(sorts[index],
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      )),
                                  selected: sortIndex == index,
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                                      borderRadius: BorderRadius.circular(10)),
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  disabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                  stops: [0.0, 0.05 * _fadeStart, 1 - 0.05 * _fadeEnd, 1.0],
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
                      child: IconButton(
                          icon: const Icon(
                            Icons.filter_list,
                            size: 30,
                          ),
                          onPressed: () async {
                            List<String> regions = loadedSkills?.map((e) => e.eventRegion!.name).toList() ?? [];
                            regions.addAll(loadedVDA?.map((e) => e.eventRegion!) ?? []);
                            regions = regions.toSet().toList();
                            regions.sort();

                            WorldRankingsFilter updatedFilter =
                                await worldRankingsFilter(context, filter, inTM, regions);
                            setState(() {
                              filter = updatedFilter;
                            });
                          })),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  String? subInfo;
                  switch (sortIndex) {
                    case 0:
                    case 1:
                      subInfo = '${teams[index].location?.city ?? ""}${teams[index].location?.city != null ? "," : ""} ${teams[index].location?.region ?? ""}';
                      break;
                    case 2:
                      subInfo = "OPR ${loadedVDA!.singleWhereOrNull((e) => e.id == teams[index].id)?.opr ?? "—"}";
                      break;
                    case 3:
                      subInfo = "DPR ${loadedVDA!.singleWhereOrNull((e) => e.id == teams[index].id)?.dpr ?? "—"}";
                      break;
                    case 4:
                      subInfo = "CCWM ${loadedVDA!.singleWhereOrNull((e) => e.id == teams[index].id)?.ccwm ?? "—"}";
                      break;
                    case 5:
                      subInfo = "${loadedVDA!.singleWhereOrNull((e) => e.id == teams[index].id)?.winPercent ?? "—"}%";
                      break;
                    case 6:
                      subInfo = "${loadedSkills!.singleWhereOrNull((e) => e.teamId == teams[index].id)?.score ?? "—"} pts";
                      break;
                    case 7:
                      subInfo = loadedVDA!.singleWhereOrNull((e) => e.id == teams[index].id)?.trueSkill.toString() ?? "—";
                      break;
                  }

                  return Column(
                    children: [
                      TeamWidget(
                        teamNumber: teams[index].teamNumber!,
                        teamID: teams[index].id,
                        subInfo: subInfo,
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
