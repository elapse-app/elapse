import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage(
      {super.key, required this.division, required this.tournament});

  final Division division;
  final Tournament tournament;

  @override
  Widget build(BuildContext context) {
    if (division.games == null || division.games!.isEmpty) {
      return const SliverToBoxAdapter(
        child: BigErrorMessage(
          icon: Icons.schedule,
          message: "No games currently scheduled",
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final game = division.games![index];
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
              ));
        },
        childCount: division.games!.length,
      ),
    );
  }
}
