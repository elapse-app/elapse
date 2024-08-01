import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/main/loaded.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TMTournamentScreen extends StatefulWidget {
  final int tournamentID;
  final bool isPreview;
  final Future<Tournament>? tournamentFuture;
  final SharedPreferences prefs;
  const TMTournamentScreen(
      {super.key,
      required this.tournamentID,
      required this.prefs,
      this.isPreview = true,
      this.tournamentFuture});

  @override
  State<TMTournamentScreen> createState() => _TMTournamentScreenState();
}

class _TMTournamentScreenState extends State<TMTournamentScreen> {
  Future<Tournament>? tournament;
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
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: CustomScrollView(
              slivers: [
                SliverAppBar.large(
                  automaticallyImplyLeading: false,
                  expandedHeight: 125,
                  centerTitle: false,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                RoundedTop()
              ],
            ),
          );
        } else if (snapshot.hasData) {
          return TournamentLoadedScreen(
            tournament: snapshot.data as Tournament,
            isPreview: widget.isPreview,
          );
        } else {
          return const Center(
            child: Text("Failed to load tournament details"),
          );
        }
      },
    );
  }
}
