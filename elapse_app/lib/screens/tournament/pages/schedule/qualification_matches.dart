import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

import '../../../../classes/Tournament/tournament_mode_functions.dart';
import '../../../../main.dart';

class MatchesView extends StatelessWidget {
  const MatchesView({
    super.key,
    required this.games,
    this.teams,
    this.teamStats,
    this.allGames,
    this.tournamentSkills,
  });

  final List<Game> games;
  final List<Team>? teams;
  final Map<int, TeamStats>? teamStats;
  final List<Game>? allGames;
  final Map<int, TournamentSkills>? tournamentSkills;

  @override
  Widget build(BuildContext context) {
    final bool useLiveTiming = prefs.getBool("useLiveTiming") ?? true;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final game = games[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Column(
              children: [
                GameWidget(
                  game: game,
                  useLiveTiming: useLiveTiming,
                  teams: teams,
                  teamStats: teamStats,
                  allGames: allGames,
                  tournamentSkills: tournamentSkills,
                ),
                index != games.length - 1
                    ? Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )
                    : Container(),
              ],
            ),
          );
        },
        childCount: games.length,
      ),
    );
  }
}
