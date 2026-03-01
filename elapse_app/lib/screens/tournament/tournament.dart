import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
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
      // Use provided future - TMTournamentDetails caches to SQLite automatically
      tournament = widget.tournamentFuture;
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
          // Tournament data is cached in SQLite by TMTournamentDetails
          // TournamentLoadedScreen will read from SQLite via getTournamentFromCache()
          return TournamentLoadedScreen(
            tournamentId: widget.tournamentID,
            isPreview: widget.isPreview,
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text("Failed to load tournament details",
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
            ),
          );
        } else {
          print(snapshot.connectionState);
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text("Failed to load tournament details",
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
