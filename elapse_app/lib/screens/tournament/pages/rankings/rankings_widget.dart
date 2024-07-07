import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class StandardRanking extends StatelessWidget {
  const StandardRanking({
    super.key,
    required this.teamStats,
    required this.rankings,
    required this.teamName,
    required this.games,
    required this.allianceColor,
  });
  final Map<int, TeamStats> rankings;
  final String teamName;
  final TeamStats teamStats;
  final List<Game>? games;
  final Color allianceColor;
  @override
  Widget build(BuildContext context) {
    int rank = teamStats.rank;
    int wins = teamStats.wins;
    int losses = teamStats.losses;
    int ties = teamStats.ties;
    int wp = teamStats.wp;
    int ap = teamStats.ap;
    return GestureDetector(
      onTap: () {
        tournamentStatsPage(context, teamStats, games, rankings, teamName);
      },
      child: Container(
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 120,
              fit: FlexFit.tight,
              child: Text(teamName,
                  style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w400,
                      color: allianceColor)),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rank $rank",
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text("$wins-$losses-$ties",
                      style: const TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
            Flexible(
              flex: 20,
              fit: FlexFit.tight,
              child: Container(
                  height: 50,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.tertiary,
                  )),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("$wp WP",
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  Text("$ap AP",
                      style: TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OPRRanking extends StatelessWidget {
  const OPRRanking(
      {super.key,
      required this.teamStats,
      required this.rankings,
      required this.teamName,
      required this.stat,
      required this.games,
      required this.allianceColor});

  final Map<int, TeamStats> rankings;
  final String stat;
  final String teamName;
  final TeamStats teamStats;
  final List<Game>? games;
  final Color allianceColor;

  @override
  Widget build(BuildContext context) {
    int rank = teamStats.rank;
    int wins = teamStats.wins;
    int losses = teamStats.losses;
    int ties = teamStats.ties;
    double opr = teamStats.opr;
    double dpr = teamStats.dpr;
    double ccwm = teamStats.ccwm;

    double value = 0;
    if (stat == "OPR") {
      value = opr;
    } else if (stat == "DPR") {
      value = dpr;
    } else if (stat == "CCWM") {
      value = ccwm;
    }
    return GestureDetector(
      onTap: () {
        tournamentStatsPage(context, teamStats, games, rankings, teamName);
      },
      child: Container(
        height: 72,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 120,
              fit: FlexFit.tight,
              child: Text(teamName,
                  style: TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w400,
                      color: allianceColor)),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Rank $rank",
                      style: const TextStyle(
                        fontSize: 16,
                      )),
                  Text("$wins-$losses-$ties",
                      style: const TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
            Flexible(
              flex: 20,
              fit: FlexFit.tight,
              child: Container(
                  height: 50,
                  child: VerticalDivider(
                    thickness: 0.5,
                    color: Theme.of(context).colorScheme.tertiary,
                  )),
            ),
            Flexible(
              flex: 50,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(stat,
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  Text("$value",
                      style: TextStyle(
                        fontSize: 16,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyRanking extends StatelessWidget {
  const EmptyRanking(
      {super.key, required this.teamName, required this.allianceColor});

  final String teamName;
  final Color allianceColor;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 72,
      child: Text(
        teamName,
        style: TextStyle(
            fontSize: 40,
            height: 1,
            fontWeight: FontWeight.w400,
            color: allianceColor),
      ),
    );
  }
}

Future<void> tournamentStatsPage(
  BuildContext context,
  TeamStats teamStats,
  List<Game>? games,
  Map<int, TeamStats> rankings,
  String teamName,
) {
  int rank = teamStats.rank;
  int wins = teamStats.wins;
  int losses = teamStats.losses;
  int ties = teamStats.ties;
  double opr = teamStats.opr;
  double dpr = teamStats.dpr;
  double ccwm = teamStats.ccwm;

  Color statsDividerColor =
      Theme.of(context).colorScheme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 55, 55, 55)
          : const Color.fromRGBO(151, 151, 151, 1);
  Color dividerColor =
      Theme.of(context).colorScheme.brightness == Brightness.dark
          ? const Color.fromARGB(255, 55, 55, 55)
          : const Color.fromARGB(255, 211, 211, 211);

  List<Game> teamGames = games!.where(
    (element) {
      return element.redAlliancePreview?[0].teamName == teamName ||
          element.redAlliancePreview?[1].teamName == teamName ||
          element.blueAlliancePreview?[0].teamName == teamName ||
          element.blueAlliancePreview?[1].teamName == teamName;
    },
  ).toList();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.8,
        minChildSize: 0,
        expand: false,
        snap: true,
        snapAnimationDuration: const Duration(milliseconds: 250),
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
                    const Icon(
                      Icons.info_outlined,
                      size: 24,
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
                          Text("$wins-$ties-$losses",
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
                          Text("000",
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w500))
                        ],
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Divider(
                        height: 3,
                        color: statsDividerColor,
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: [
                          Column(
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
                            ),
                            Divider(
                              height: 3,
                              color: dividerColor,
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
