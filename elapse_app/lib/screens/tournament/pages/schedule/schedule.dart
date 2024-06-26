import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/requests/schedule.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage(
      {super.key, required this.tournamentID, required this.divisionID});

  final int tournamentID;
  final int? divisionID;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  Future<List<Game>>? games;

  @override
  void initState() {
    super.initState();

    if (widget.divisionID != null) {
      games = getTournamentSchedule(widget.tournamentID, widget.divisionID!);
    }
  }

  void didUpdateWidget(covariant SchedulePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.divisionID != oldWidget.divisionID) {
      games = getTournamentSchedule(widget.tournamentID, widget.divisionID!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: games,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Text("Failed to load schedule"),
            ),
          );
        }
        if (snapshot.hasData) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final game = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      GameWidget(game: game),
                      index != snapshot.data!.length - 1
                          ? const Divider(
                              height: 3,
                              color: Color.fromRGBO(123, 123, 123, 1),
                            )
                          : Container(),
                    ],
                  ),
                );
              },
              childCount: snapshot.data!.length,
            ),
          );
        } else {
          return SliverToBoxAdapter();
        }
      }),
    );
  }
}
