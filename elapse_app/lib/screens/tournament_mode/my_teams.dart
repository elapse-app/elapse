import 'dart:convert';

import 'package:elapse_app/aesthetics/color_pallete.dart';
import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/classes/Filters/season.dart';
import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Team/world_skills.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/classes/Tournament/tournament_mode_functions.dart';
import 'package:elapse_app/screens/my_team/my_team.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:elapse_app/screens/tournament_mode/widgets/ranking_overview_widget.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

class TMMyTeams extends StatefulWidget {
  const TMMyTeams({super.key, required this.tournamentID});
  final int tournamentID;

  @override
  State<TMMyTeams> createState() => TMMyTeamsState();
}

class TMMyTeamsState extends State<TMMyTeams> {
  late String savedTeam;
  late TeamPreview savedTeamPreview;

  List<TeamPreview> savedTeamPreviews = [];
  List<String> savedTeamStrings = [];

  late TeamPreview selectedTeamPreview;
  late Season season;

  Future<Tournament>? tournament;

  int seasonID = 190;
  @override
  void initState() {
    super.initState();
    reload();
  }

  void reload() {
    final String savedTeam = prefs.getString("savedTeam") ?? "";
    final parsed = jsonDecode(savedTeam);
    savedTeamPreview = TeamPreview(teamID: parsed["teamID"], teamNumber: parsed["teamNumber"]);

    tournament = TMTournamentDetails(widget.tournamentID);

    savedTeamStrings = prefs.getStringList("savedTeams") ?? [];
    savedTeamPreviews.add(savedTeamPreview);
    savedTeamPreviews.addAll(savedTeamStrings
        .map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"]))
        .toList());

    selectedTeamPreview = savedTeamPreview;

    savedTeamPreviews = savedTeamPreviews.toSet().toList();
    season = seasons[0];
    team = fetchTeam(savedTeamPreview.teamID);
    teamStats = getTrueSkillDataForTeam(season.vrcId, savedTeamPreview.teamNumber);
    skillsStats = getWorldSkillsForTeam(season.vrcId, savedTeamPreview.teamID);
    teamTournaments = fetchTeamTournaments(savedTeamPreview.teamID, season.vrcId);
    teamAwards = getAwards(savedTeamPreview.teamID, season.vrcId);
  }

  void teamChange(TeamPreview? value) {
    if (value != null) {
      setState(() {
        selectedTeamPreview = value;
        team = fetchTeam(value.teamID);
        teamStats = getTrueSkillDataForTeam(seasonID, value.teamNumber);
        teamTournaments = fetchTeamTournaments(value.teamID, seasonID);
        teamAwards = getAwards(value.teamID, seasonID);
      });
    }
  }

  Future<Team>? team;
  Future<VDAStats?>? teamStats;
  Future<List<TournamentPreview>>? teamTournaments;
  Future<WorldSkillsStats>? skillsStats;
  Future<List<Award>>? teamAwards;
  @override
  Widget build(BuildContext context) {
    ColorPallete colorPallete;
    if (Theme.of(context).colorScheme.brightness == Brightness.dark) {
      colorPallete = darkPallete;
    } else {
      colorPallete = lightPallete;
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: const Text(
              "My Team",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            includeSettings: true,
            background: Padding(
              padding: const EdgeInsets.only(left: 23, right: 12, top: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
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
                          skillsStats = getWorldSkillsForTeam(season.vrcId, savedTeamPreview.teamID);
                          teamStats = getTrueSkillDataForTeam(season.vrcId, savedTeamPreview.teamNumber);
                          teamTournaments = fetchTeamTournaments(savedTeamPreview.teamID, season.vrcId);
                          teamAwards = getAwards(savedTeamPreview.teamID, season.vrcId);
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
                      ])),
                  const Spacer(),
                  SettingsButton(callback: () {
                    setState(() {
                      reload();
                    });
                  }),
                ],
              ),
            ),
          ),
          const RoundedTop(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18), color: Theme.of(context).colorScheme.tertiary),
                padding: const EdgeInsets.only(left: 18, right: 18, bottom: 18, top: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savedTeamPreview.teamNumber,
                      style: const TextStyle(
                        fontSize: 64,
                        height: 1.0,
                        letterSpacing: -2,
                        fontWeight: FontWeight.w400,
                      ),
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
                                    Container(width: 75, child: const LinearProgressIndicator()),
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
                                    Container(width: 75, child: const LinearProgressIndicator()),
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
                                    const Spacer(),
                                    Text(
                                      qualificationString,
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
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
                                    const Spacer(),
                                    Text(
                                      "${stats.winPercent == null ? "" : stats.winPercent!.toStringAsFixed(1)}%",
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
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
                    FutureBuilder(
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
                          return TeamBio(grade: "", location: Location(), teamName: "", organization: "");
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder(
                  future: tournament,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Tournament tournament = snapshot.data as Tournament;
                      if (!tournament.teams.any(
                        (element) {
                          return element.teamNumber == selectedTeamPreview.teamNumber;
                        },
                      )) {
                        return Container();
                      }
                      if (tournament.divisions[0].games?.isEmpty ?? true) {
                        return Container();
                      }
                      return Container(
                        margin: EdgeInsets.only(top: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "This Tournament",
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RankingOverviewWidget(
                                teamStats: tournament.divisions[0].teamStats![selectedTeamPreview.teamID]!,
                                skills: tournament.tournamentSkills!,
                                teamID: selectedTeamPreview.teamID),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              children:
                                  getTeamGames(tournament.divisions[0].games!, selectedTeamPreview.teamNumber).map(
                                (e) {
                                  return Column(
                                    children: [
                                      GameWidget(
                                        game: e,
                                        teamName: selectedTeamPreview.teamNumber,
                                        isAllianceColoured: false,
                                      ),
                                      Divider(
                                        color: Theme.of(context).colorScheme.surfaceDim,
                                      )
                                    ],
                                  );
                                },
                              ).toList(),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
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
                      if (snapshot.hasData) {
                        VDAStats stats = snapshot.data as VDAStats;
                        if (stats.worldSkillsRank == null) {
                          stats.worldSkillsRank = 0;
                          stats.skillsScore = 0;
                          stats.maxDriver = 0;
                          stats.maxAuto = 0;
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stats.worldSkillsRank.toString(),
                              style: const TextStyle(fontSize: 64, height: 1, letterSpacing: -2),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              "World Skills Rank",
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
                                      stats.skillsScore.toString(),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Score", style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stats.maxDriver.toString(),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Driver", style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stats.maxAuto.toString(),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Auto", style: TextStyle(fontSize: 16))
                                  ],
                                )
                              ],
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return const Text("Skills Data Unavailable");
                      } else {
                        return const Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
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
                      if (snapshot.hasData) {
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
                              style: const TextStyle(fontSize: 64, height: 1, letterSpacing: -2),
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Score", style: TextStyle(fontSize: 16))
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("Region Rank", style: TextStyle(fontSize: 16))
                                  ],
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                              ],
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
                                      stats.opr.toString(),
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("OPR", style: TextStyle(fontSize: 16))
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("DPR", style: TextStyle(fontSize: 16))
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
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                    ),
                                    const Text("CCWM", style: TextStyle(fontSize: 16))
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return const Text("TrueSkill Data Unavailable");
                      } else {
                        return const Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(18),
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
                    const Text("Totals", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 18),
                    FutureBuilder(
                      future: teamStats,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
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
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const Text("Wins", style: TextStyle(fontSize: 16))
                                ],
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stats.losses.toString(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const Text("Losses", style: TextStyle(fontSize: 16))
                                ],
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stats.ties.toString(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const Text("Ties", style: TextStyle(fontSize: 16))
                                ],
                              ),
                              const SizedBox(width: 18),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stats.matches.toString(),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  const Text("Matches", style: TextStyle(fontSize: 16))
                                ],
                              ),
                              const SizedBox(width: 18),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return const Text("Total Stats Unavailable");
                        } else {
                          return const Center(
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 23),
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
                      if (awards.isNotEmpty)
                        return Container(
                          padding: const EdgeInsets.all(18),
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
                                  const Text("Awards", style: TextStyle(fontSize: 24)),
                                  Text(awards.length.toString(),
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500))
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
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              e.name,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.start,
                                              maxLines: 1,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                                        color: Theme.of(context).colorScheme.surfaceDim,
                                      )
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      else
                        return Container();
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
                  const SizedBox(
                    height: 18,
                  ),
                  FutureBuilder(
                    future: teamTournaments,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<TournamentPreview> tournaments = snapshot.data as List<TournamentPreview>;
                        return Column(
                          children: tournaments
                              .map(
                                (e) => TournamentPreviewWidget(tournamentPreview: e),
                              )
                              .toList(),
                        );
                      } else if (snapshot.hasError) {
                        return Container();
                      } else {
                        return Container();
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          selectedTeamPreview != savedTeamPreview
              ? SliverToBoxAdapter(
                  child: TextButton(
                    child: Text(
                      "Remove Team",
                      style: TextStyle(fontSize: 18, color: colorPallete.redAllianceText),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          savedTeamPreviews.remove(selectedTeamPreview);
                          savedTeamStrings.remove(
                              '{"teamID": ${selectedTeamPreview.teamID}, "teamNumber": "${selectedTeamPreview.teamNumber}"}');
                          prefs.setStringList("savedTeams", savedTeamStrings);
                          selectedTeamPreview = savedTeamPreviews[0];
                          teamChange(selectedTeamPreview);
                        },
                      );
                    },
                  ),
                )
              : SliverToBoxAdapter()
        ],
      ),
    );
  }
}
