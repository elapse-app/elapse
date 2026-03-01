import 'dart:async';

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
  late Stream<Tournament> _tournamentStream;
  StreamSubscription<Tournament>? _subscription;
  Tournament? _tournament;
  Object? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();

    if (widget.tournamentFuture != null) {
      _tournamentStream = widget.tournamentFuture!.asStream();
    } else {
      _tournamentStream = streamTMTournamentDetails(widget.tournamentID);
    }

    _subscription = _tournamentStream.listen(
      (tournament) {
        if (mounted) setState(() => _tournament = tournament);
      },
      onError: (error) {
        if (mounted) setState(() => _error = error);
      },
      onDone: () {
        if (mounted) setState(() => _done = true);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tournament != null) {
      return TournamentLoadedScreen(
        tournamentId: widget.tournamentID,
        tournament: _tournament!,
        isFullyLoaded: _done,
        isPreview: widget.isPreview,
      );
    } else if (_error != null) {
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
      return const TournamentLoadingScreen();
    }
  }
}
