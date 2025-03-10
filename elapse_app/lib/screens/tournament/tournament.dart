import 'dart:convert';

import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/main/loaded.dart';
import 'package:elapse_app/screens/tournament/pages/main/loading.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';

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
      tournament = widget.tournamentFuture;
    } else {
      tournament = getTournamentDetails(widget.tournamentID);
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
          Tournament tournament = snapshot.data! as Tournament;
          prefs.setString(
              "recently-opened-tournament", jsonEncode(tournament.toJson()));
          return TournamentLoadedScreen(
            tournament: tournament,
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
