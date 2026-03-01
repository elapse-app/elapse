import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/main/loaded.dart';
import 'package:elapse_app/screens/widgets/elapse_loading_indicator.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';

class TMTournamentScreen extends StatefulWidget {
  final int tournamentID;
  final bool isPreview;
  const TMTournamentScreen({
    super.key,
    required this.tournamentID,
    this.isPreview = true,
  });

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
    // Use cache when valid (30s expiry) for offline resilience
    // forceRefresh only used on explicit pull-to-refresh
    tournament = TMTournamentDetails(widget.tournamentID);
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
                SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverHeaderDelegate(
                      minHeight: 70.0,
                      maxHeight: 70.0,
                      child: Hero(
                        tag: "top",
                        child: Stack(
                          children: [
                            Container(
                                height: 300,
                                color: Theme.of(context).colorScheme.primary),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 13),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildIconButton(
                                        context, Icons.schedule, 0),
                                    _buildIconButton(context,
                                        Icons.format_list_numbered_outlined, 1),
                                    _buildIconButton(context,
                                        Icons.sports_esports_outlined, 2),
                                    _buildIconButton(
                                        context, Icons.info_outlined, 3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                SliverToBoxAdapter(
                  child: ElapseLoadingIndicator(
                    message: "Loading tournament",
                    size: LoadingSize.section,
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          // Tournament data is cached in SQLite by TMTournamentDetails
          // TournamentLoadedScreen will read from SQLite via getTournamentFromCache()
          return TournamentLoadedScreen(
            tournamentId: widget.tournamentID,
            isPreview: widget.isPreview,
          );
        } else {
          print(snapshot.error.toString());
          print(snapshot.error.toString());
          debugPrintStack(stackTrace: snapshot.stackTrace);
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

  Widget _buildIconButton(BuildContext context, IconData icon, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
        ),
        IconButton(
          icon: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () async {},
        ),
      ],
    );
  }
}
