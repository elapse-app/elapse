import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:flutter/material.dart';

class RankingOverviewWidget extends StatelessWidget {
  const RankingOverviewWidget(
      {super.key,
      required this.teamStats,
      required this.skills,
      required this.teamID});
  final TeamStats teamStats;
  final Map<int, TournamentSkills> skills;
  final int teamID;

  @override
  Widget build(BuildContext context) {
    int rank = teamStats.rank;
    int wins = teamStats.wins;
    int losses = teamStats.losses;
    int ties = teamStats.ties;
    double opr = teamStats.opr;
    double dpr = teamStats.dpr;
    double ccwm = teamStats.ccwm;
    return Container(
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
    );
  }
}
