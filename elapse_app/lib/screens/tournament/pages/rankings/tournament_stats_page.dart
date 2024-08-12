import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

Future<void> tournamentStatsPage(
    BuildContext context,
    TeamStats teamStats,
    List<Game>? games,
    Map<int, TeamStats> rankings,
    Map<int, TournamentSkills> skills,
    String teamName,
    int teamID,
    {Team? team}) {
  int rank = teamStats.rank;
  int wins = teamStats.wins;
  int losses = teamStats.losses;
  int ties = teamStats.ties;
  double opr = teamStats.opr;
  double dpr = teamStats.dpr;
  double ccwm = teamStats.ccwm;

  List<Game> teamGames = games!.where(
    (element) {
      return element.redAlliancePreview?[0].teamNumber == teamName ||
          element.redAlliancePreview?[1].teamNumber == teamName ||
          element.blueAlliancePreview?[0].teamNumber == teamName ||
          element.blueAlliancePreview?[1].teamNumber == teamName;
    },
  ).toList();

  final DraggableScrollableController dra = DraggableScrollableController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        minChildSize: 0.5,
        expand: false,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$teamName Stats",
                      style: const TextStyle(
                          fontSize: 24, height: 1, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      iconAlignment: IconAlignment.end,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamScreen(
                              teamID: teamID,
                              teamName: teamName,
                              team: team,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            "View More",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Theme.of(context).colorScheme.primary),
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$rank",
                                style: const TextStyle(
                                    fontSize: 64, letterSpacing: -2, height: 1),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              const Text(
                                "Rank",
                                style: TextStyle(fontSize: 16, height: 1),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 125,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${teamStats.wp}",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          height: 1),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "WP",
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${teamStats.ap}",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          height: 1),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "AP",
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${teamStats.sp}",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          height: 1),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      "SP",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Record",
                            style: TextStyle(fontSize: 24),
                          ),
                          Text("$wins-$losses-$ties",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500))
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Skills Rank",
                            style: TextStyle(fontSize: 24),
                          ),
                          Text("${skills[teamID]?.rank ?? "N/A"}",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500))
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Divider(
                        height: 3,
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
                                "$opr",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const Text(
                                "OPR",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$dpr",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "DPR",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 18,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$ccwm",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "CCWM",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                const Text(
                  "Matches",
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Column(
                  children: teamGames
                      .map(
                        (game) => Column(
                          children: [
                            GameWidget(
                              game: game,
                              games: games,
                              rankings: rankings,
                              teamName: teamName,
                              skills: skills,
                              isAllianceColoured: false,
                            ),
                            Divider(
                              height: 3,
                              color: Theme.of(context).colorScheme.surfaceDim,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
                // Add more content here if needed
              ],
            ),
          );
        },
      );
    },
  );
}
