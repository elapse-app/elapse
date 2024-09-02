import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/custom_tab_bar.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

import '../../classes/Filters/season.dart';
import '../../classes/Team/world_skills.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen(
      {super.key, required this.teamID, required this.teamName, this.team});
  final int teamID;
  final String teamName;
  final Team? team;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late TeamPreview teamSave;
  bool locationLoaded = false;
  @override
  void initState() {
    super.initState();
    teamSave = TeamPreview(teamID: widget.teamID, teamNumber: widget.teamName);
    isSaved = false;
    displaySave = true;
    team = fetchTeam(widget.teamID).then(
      (value) {
        setState(() {
          teamSave.location = value.location;
          teamSave.teamName = value.teamName;
          teamSave.gradeLevel = value.grade;
          locationLoaded = true;
        });
        return value;
      },
    );
    season = seasons[0];
    teamStats = getTrueSkillDataForTeam(season.vrcId, widget.teamName);
    skillsStats = getWorldSkillsForTeam(season.vrcId, widget.teamID);
    teamTournaments = fetchTeamTournaments(widget.teamID, season.vrcId);
    teamAwards = getAwards(widget.teamID, season.vrcId);
    isSaved = alreadySaved();
    displaySave = !isMainTeam();
  }

  bool alreadySaved() {
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    return savedTeams.any((element) {
          return jsonDecode(element)["teamID"] == widget.teamID;
        }) ||
        isMainTeam();
  }

  bool isMainTeam() {
    return jsonDecode(prefs.getString("savedTeam") ?? "")["teamID"] ==
        widget.teamID.toString();
  }

  void toggleSaveTeam() {
    if (!locationLoaded) {
      return;
    }
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    if (isSaved) {
      savedTeams.removeWhere((test) {
        return jsonDecode(test)["teamID"] == widget.teamID;
      });
    } else {
      savedTeams.add(jsonEncode(teamSave.toJson()));
    }
    prefs.setStringList("savedTeams", savedTeams);
    setState(() {
      isSaved = !isSaved;
    });
  }

  Future<Team>? team;
  Future<VDAStats?>? teamStats;
  Future<WorldSkillsStats>? skillsStats;
  Future<List<TournamentPreview>>? teamTournaments;
  Future<List<Award>>? teamAwards;

  late Season season;

  late bool isSaved;
  late bool displaySave;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: const Text(
              "Team Info",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
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
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface),
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: () async {
                        Season updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeasonFilterPage(selected: season),
                          ),
                        );
                        setState(() {
                          season = updated;
                          skillsStats = getWorldSkillsForTeam(season.vrcId, widget.teamID);
                          teamStats = getTrueSkillDataForTeam(season.vrcId, widget.teamName);
                          teamTournaments = fetchTeamTournaments(widget.teamID, season.vrcId);
                          teamAwards = getAwards(widget.teamID, season.vrcId);
                        });
                      },
                      child: Row(
                          children: [
                            const Icon(Icons.event_note),
                            const SizedBox(width: 4),
                            Text(
                              season.name.substring(10),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.arrow_right)
                          ]
                      )
                  )
                ],
              ),
            ),
          ),
          CustomTabBar(tabs: ["Details", "Scoutsheet"], onPressed: (value) {}),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Theme.of(context).colorScheme.tertiary),
                padding: const EdgeInsets.only(
                    left: 18, right: 18, bottom: 18, top: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.teamName,
                          style: const TextStyle(
                              fontSize: 64, height: 1, letterSpacing: -2),
                        ),
                        displaySave
                            ? IconButton(
                                focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.only(
                                    left: 10, top: 10, bottom: 10),
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  isSaved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_add_outlined,
                                  size: 36,
                                ),
                                onPressed: toggleSaveTeam)
                            : Container()
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      "Team Number",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                    FutureBuilder(
                      future: teamStats,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Qualifications",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    const Spacer(),
                                    Container(
                                        width: 75,
                                        child: LinearProgressIndicator()),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Win Rate",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    const Spacer(),
                                    Container(
                                        width: 75,
                                        child: LinearProgressIndicator()),
                                  ],
                                ),
                              ],
                            );
                          case ConnectionState.done:
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Text("No Data Available");
                            }

                            VDAStats stats = snapshot.data as VDAStats;
                            List<String> qualifications = [];
                            String qualificationString = "";
                            if (stats.regionalQual == 1) {
                              qualifications.add("RC");
                            }
                            if (stats.worldsQual == 1) {
                              qualifications.add("WC");
                            }
                            for (int i = 0; i < qualifications.length; i++) {
                              qualificationString += qualifications[i];
                              if (i != qualifications.length - 1) {
                                qualificationString += ", ";
                              }
                            }
                            if (qualificationString == "") {
                              qualificationString = "NQ";
                            }
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Qualifications",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    Spacer(),
                                    Text(
                                      qualificationString,
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      "Win Rate",
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    Spacer(),
                                    Text(
                                      "${stats.winPercent == null ? "" : stats.winPercent!.toStringAsFixed(1)}%",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            );
                        }
                      },
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Divider(
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    widget.team == null
                        ? FutureBuilder(
                            future: team,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                Team team = snapshot.data as Team;
                                return TeamBio(
                                  grade: team.grade?.name ?? "",
                                  location: team.location ?? Location(),
                                  teamName: team.teamName ?? "",
                                  organization: team.organization ?? "",
                                );
                              } else if (snapshot.hasError) {
                                return TeamBio(
                                  grade: "",
                                  location: Location(),
                                  teamName: "",
                                  organization: "",
                                );
                              } else {
                                return TeamBio(
                                    grade: "",
                                    location: Location(),
                                    teamName: "",
                                    organization: "");
                              }
                            },
                          )
                        : TeamBio(
                            grade: getGrade(widget.team?.grade?.name),
                            location: widget.team?.location ?? Location(),
                            teamName: widget.team?.teamName ?? "",
                            organization: widget.team?.organization ?? ""),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 28),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: FutureBuilder<Object>(
                    future: skillsStats,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return const Text("Skills Data Unavailable");
                          }

                          WorldSkillsStats stats = snapshot.data as WorldSkillsStats;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stats.rank.toString(),
                                style: const TextStyle(
                                    fontSize: 64, height: 1, letterSpacing: -2),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "World Skills Rank",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.score.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("Score",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.driver.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("Driver",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.auton.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("Auto",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  )
                                ],
                              ),
                            ],
                          );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 28),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: FutureBuilder<Object?>(
                    future: teamStats,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError || snapshot.data == null) {
                            return const Text("TrueSkill Data Unavailable");
                          }

                          VDAStats stats = snapshot.data as VDAStats;
                          if (stats.trueSkill == null) {
                            stats.trueSkillGlobalRank = 0;
                            stats.trueSkill = 0;
                            stats.trueSkillRegionRank = 0;
                            stats.opr = 0;
                            stats.dpr = 0;
                            stats.ccwm = 0;
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stats.trueSkillGlobalRank.toString(),
                                style: const TextStyle(
                                    fontSize: 64, height: 1, letterSpacing: -2),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              const Text(
                                "True Skill Rank",
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.trueSkill.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("Score",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.trueSkillRegionRank.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("Region Rank",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 18,
                              ),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.opr.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("OPR",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.dpr.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("DPR",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 18,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stats.ccwm.toString(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const Text("CCWM",
                                          style: TextStyle(fontSize: 16))
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: const SizedBox(
              height: 28,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Totals", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 18),
                    FutureBuilder(
                      future: teamStats,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return const Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          case ConnectionState.done:
                            if (snapshot.hasError || snapshot.data == null) {
                              return const Text("Total Stats Unavailable");
                            }

                            VDAStats stats = snapshot.data as VDAStats;
                            if (stats.wins == null) {
                              stats.wins = 0;
                              stats.losses = 0;
                              stats.ties = 0;
                              stats.matches = 0;
                            }
                            return Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stats.wins.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Wins",
                                        style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stats.losses.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Losses",
                                        style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stats.ties.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Ties",
                                        style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(width: 18),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stats.matches.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Matches",
                                        style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(width: 18),
                              ],
                            );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder(
                future: teamAwards,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return const Text("Awards Unavailable");
                      }

                      List<Award> awards = snapshot.data as List<Award>;
                      return Container(
                        padding: EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Awards", style: TextStyle(fontSize: 24)),
                                Text(awards.length.toString(),
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                            const SizedBox(height: 18),
                            Column(
                              children: awards.map((e) {
                                return Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      height: 60,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            e.name,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.start,
                                            maxLines: 1,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.start,
                                            e.tournamentName ?? "",
                                            style: const TextStyle(fontSize: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceDim,
                                    )
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tournaments",
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  FutureBuilder(
                    future: teamTournaments,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return const Text("Tournaments Unavailable");
                          }

                          List<TournamentPreview> tournaments =
                          snapshot.data as List<TournamentPreview>;
                          return Column(
                            children: tournaments
                                .map(
                                  (e) => TournamentPreviewWidget(
                                  tournamentPreview: e),
                            )
                                .toList(),
                          );
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class TeamBio extends StatelessWidget {
  const TeamBio({
    super.key,
    required this.grade,
    required this.location,
    required this.teamName,
    required this.organization,
  });

  final String grade;
  final Location location;
  final String teamName;
  final String organization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getGrade(grade),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Grade",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getLocation(location),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Location",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 25,
        ),
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 12,
              fit: FlexFit.tight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    "Team Name",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String getGrade(String? grade) {
  if (grade == "High School") {
    return "HS";
  } else if (grade == "Middle School") {
    return "MS";
  } else if (grade == "College") {
    return "CG";
  } else {
    return "NG";
  }
}

String getLocation(Location? location) {
  if (location?.city != null) {
    return "${location!.city}, ${location.region}";
  } else {
    return "No Location";
  }
}
