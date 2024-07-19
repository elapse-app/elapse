import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage(
      {super.key,
      required this.division,
      required this.tournament,
      required this.searchQuery});

  final Division division;
  final Tournament tournament;
  final String searchQuery;

  @override
  @override
  Widget build(BuildContext context) {
    List<Game> filteredGames;
    if (division.games != null) {
      filteredGames = division.games!.where((e) {
        if (searchQuery.isEmpty) {
          return true;
        }
        return e.blueAlliancePreview![0].teamName
                .contains(searchQuery.toUpperCase()) ||
            e.blueAlliancePreview![1].teamName
                .contains(searchQuery.toUpperCase()) ||
            e.redAlliancePreview![0].teamName
                .contains(searchQuery.toUpperCase()) ||
            e.redAlliancePreview![1].teamName
                .contains(searchQuery.toUpperCase()) ||
            e.gameName.contains(searchQuery.toUpperCase());
      }).toList();
    } else {
      filteredGames = [];
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final game = filteredGames[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Column(
              children: [
                GameWidget(
                  game: game,
                  rankings: division.teamStats,
                  games: division.games!,
                  skills: tournament.tournamentSkills,
                ),
                index != division.games!.length - 1
                    ? Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )
                    : Container(),
              ],
            ),
          );
        },
        childCount: filteredGames.length,
      ),
    );
  }
}
