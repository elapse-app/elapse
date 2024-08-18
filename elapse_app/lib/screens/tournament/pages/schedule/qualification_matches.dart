import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class MatchesView extends StatelessWidget {
  const MatchesView(
      {super.key, required this.games, required this.useLiveTiming});

  final List<Game> games;
  final bool useLiveTiming;

  @override
  Widget build(BuildContext context) {
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
