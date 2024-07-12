import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required this.division});

  final Division division;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  @override
  @override
  Widget build(BuildContext context) {
    calcEventStats(53690, 10);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final game = widget.division.games![index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23.0),
            child: Column(
              children: [
                GameWidget(
                  game: game,
                  rankings: widget.division.teamStats,
                  games: widget.division.games!,
                ),
                index != widget.division.games!.length - 1
                    ? Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )
                    : Container(),
              ],
            ),
          );
        },
        childCount: widget.division.games?.length ?? 0,
      ),
    );
  }
}
