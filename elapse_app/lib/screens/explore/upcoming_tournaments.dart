import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../classes/Tournament/tournament_preview.dart';
import '../tournament/tournament.dart';
import '../widgets/big_error_message.dart';
import 'filters.dart';

class UpcomingTournaments extends StatefulWidget {
  const UpcomingTournaments({
    super.key,
    required this.filter,
  });

  final ExploreSearchFilter filter;

  @override
  State<UpcomingTournaments> createState() => _UpcomingTournamentsState();
}

class _UpcomingTournamentsState extends State<UpcomingTournaments> {
  late Future<TournamentList> upcomingTournaments;

  @override
  void initState() {
    super.initState();
    upcomingTournaments = getTournaments("", widget.filter, getAllPages: true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: upcomingTournaments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 100,
                width: 100,
                child: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasData) {
            return _LoadedUpcomingTournaments(
                tournaments: (snapshot.data as TournamentList).tournaments);
          } else {
            print(snapshot.error);
            return const Center(
              child: BigErrorMessage(
                icon: Icons.emoji_events_outlined,
                message: "Unable to load upcoming events",
                topPadding: 15,
                textPadding: 10,
              ),
            );
          }
        });
  }
}

class _LoadedUpcomingTournaments extends StatelessWidget {
  const _LoadedUpcomingTournaments({required this.tournaments});

  final List<TournamentPreview> tournaments;

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return const Center(
        child: BigErrorMessage(
          icon: Icons.emoji_events_outlined,
          message: "No upcoming events",
          topPadding: 15,
          textPadding: 10,
        ),
      );
    }

    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 5),
        itemCount: tournaments.length,
        itemBuilder: (context, index) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 20, vertical: 10),
                      margin: const EdgeInsets.all(8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tournaments[index].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${tournaments[index].location?.city ?? ""}, ${tournaments[index].location?.region ?? ""}  -  ${DateFormat("yyyy/MM/dd").format(tournaments[index].startDate!)} ${tournaments[index].startDate != tournaments[index].endDate ? "- ${DateFormat("yyyy/MM/dd").format(tournaments[index].endDate!)}" : ""}",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  ]),
                            ),
                            DateTime.now().isAfter(
                                    tournaments[index].startDate ??
                                        DateTime.now())
                                ? const Icon(Icons.adjust, color: Colors.green)
                                : const SizedBox(),
                            const Icon(Icons.arrow_right),
                          ]),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentScreen(
                                tournamentID: tournaments[index].id),
                          ));
                    }),
                index != tournaments.length - 1
                    ? Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )
                    : Container(),
              ]);
        });
  }
}
