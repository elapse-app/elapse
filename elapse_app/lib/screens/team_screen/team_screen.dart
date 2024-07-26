import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/screens/tournament/widgets/tournament_preview_widget.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';

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
  @override
  void initState() {
    super.initState();
    team = fetchTeam(widget.teamID);
    teamStats = getTrueSkillDataForTeam(widget.teamName);
    teamTournaments = fetchTeamTournaments(widget.teamID, 181);
    teamAwards = getAwards(widget.teamID, 181);
  }

  Future<Team>? team;
  Future<VDAStats>? teamStats;
  Future<List<TournamentPreview>>? teamTournaments;
  Future<List<Award>>? teamAwards;
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
                      "Team Info",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              background: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 12, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          SettingsButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          const RoundedTop(),
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
                    Text(
                      widget.teamName,
                      style: const TextStyle(
                          fontSize: 64, height: 1, letterSpacing: -2),
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
                                    "${stats.winPercent}%",
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          print(snapshot.error);
                          return Text("${snapshot.error}");
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
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Flexible(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getGrade(team.grade),
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                          flex: 17,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                getLocation(team.location),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                      height: 18,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(team.teamName ?? "",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                        const Text(
                                          "Team Name",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              } else if (snapshot.hasError) {
                                return const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "Grade",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: 18),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text(
                                              "Grade",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                          "Organization",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child:
                                                  CircularProgressIndicator(),
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Grade",
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 18),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              child:
                                                  CircularProgressIndicator(),
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Location",
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: CircularProgressIndicator(),
                                          width: 20,
                                          height: 20,
                                        ),
                                        const Text(
                                          "Organization",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flex(
                                direction: Axis.horizontal,
                                children: [
                                  Flexible(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          getGrade(widget.team?.grade),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
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
                                    flex: 17,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          textWidthBasis: TextWidthBasis.parent,
                                          getLocation(widget.team?.location),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const Text(
                                          "Location",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 18,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.team?.organization ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                  const Text(
                                    "Organization",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
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
                                      stats.maxDriver.toString(),
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
                                      stats.maxAuto.toString(),
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
                      } else if (snapshot.hasError) {
                        return const Text("An error occured");
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
                      } else if (snapshot.hasError) {
                        return const Text("An error occured");
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
                                          e.tournament?.name ?? "",
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
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
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
                                (e) => TournamentPreviewWidget(
                                    tournamentPreview: e),
                              )
                              .toList(),
                        );
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
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
              height: 50,
            ),
          )
        ],
      ),
    );
  }
}

String getGrade(String? grade) {
  if (grade == "High School") {
    return "HS";
  } else if (grade == "Middle School") {
    return "MS";
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
