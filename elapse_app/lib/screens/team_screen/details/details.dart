import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/my_team/my_team.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';

List<Widget> Details(
    BuildContext context,
    String teamNumber,
    bool displaySave,
    bool isSaved,
    void Function() toggleSaveTeam,
    Team? team,
    Future? teamFuture,
    Future<VDAStats>? teamStats,
    Future? teamAwards,
    Future? teamTournaments) {
  return [
    SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Theme.of(context).colorScheme.tertiary),
          padding:
              const EdgeInsets.only(left: 18, right: 18, bottom: 18, top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    teamNumber,
                    style: const TextStyle(
                        fontSize: 64, height: 1, letterSpacing: -2),
                  ),
                  displaySave
                      ? IconButton(
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          padding:
                              EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                  if (snapshot.hasData) {
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
                                  fontSize: 24, fontWeight: FontWeight.w500),
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
                              "${stats.winPercent == null ? "" : stats.winPercent}%",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Container();
                  } else {
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
                                width: 75, child: LinearProgressIndicator()),
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
                                width: 75, child: LinearProgressIndicator()),
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
              team == null
                  ? FutureBuilder(
                      future: teamFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Team team = snapshot.data as Team;
                          return TeamBio(
                            grade: team.grade ?? "",
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
                      grade: getGrade(team.grade),
                      location: team.location ?? Location(),
                      teamName: team.teamName ?? "",
                      organization: team.organization ?? ""),
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
                                stats.skillsScore.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                                stats.maxDriver.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                                stats.maxAuto.toString(),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
            child: FutureBuilder<Object>(
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
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
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
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const Text("Matches",
                                style: TextStyle(fontSize: 16))
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
      padding: EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverToBoxAdapter(
        child: FutureBuilder(
          future: teamAwards,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
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
                                fontSize: 24, fontWeight: FontWeight.w500))
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
                              color: Theme.of(context).colorScheme.surfaceDim,
                            )
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Container();
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
                if (snapshot.hasData) {
                  List<TournamentPreview> tournaments =
                      snapshot.data as List<TournamentPreview>;
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
        height: 10,
      ),
    ),
  ];
  ;
}
