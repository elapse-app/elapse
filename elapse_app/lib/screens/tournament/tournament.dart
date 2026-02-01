import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/database/cache_manager.dart';
import 'package:elapse_app/screens/tournament/pages/main/loaded.dart';
import 'package:elapse_app/screens/tournament/pages/main/loading.dart';
import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  final int tournamentID;
  final bool isPreview;
  final Future<Tournament>? tournamentFuture;
  const TournamentScreen({
    super.key,
    required this.tournamentID,
    this.isPreview = true,
    this.tournamentFuture,
  });

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  Future<Tournament>? tournament;
  Future<List<dynamic>>? tournamentAndPrefs;
  int selectedIndex = 0;

  Division? division;

  List<String> titles = ["Schedule", "Rankings", "Skills", "Info"];

  @override
  void initState() {
    super.initState();

    if (widget.tournamentFuture != null) {
      // Wrap the provided future to ensure it sets the in-memory cache
      // This is critical for TournamentLoadedScreen which uses getLastLoadedTournament()
      tournament = widget.tournamentFuture!.then((t) {
        CacheManager.setLastLoadedTournament(t);
        return t;
      });
    } else {
      // Use TMTournamentDetails to leverage SQLite caching
      // This ensures previewed tournaments are cached for offline access
      tournament = TMTournamentDetails(widget.tournamentID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: tournament,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TournamentLoadingScreen();
        } else if (snapshot.hasData) {
          // TMTournamentDetails already set the in-memory cache
          // TournamentLoadedScreen will use getLastLoadedTournament() for sync access
          return TournamentLoadedScreen(
            tournamentId: widget.tournamentID,
            isPreview: widget.isPreview,
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return const Center(
            child: Text("Failed to load tournament details"),
          );
        } else {
          print(snapshot.connectionState);
          return const Center(
            child: Text("Failed to load tournament details"),
          );
        }
      },
    );
  }
}
