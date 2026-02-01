import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/league_session.dart';
import 'package:elapse_app/classes/Tournament/tournament_mode_functions.dart';
import 'package:elapse_app/database/cache_manager.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/pages/main/search_screen.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:elapse_app/screens/tournament_mode/widgets/next_game.dart';
import 'package:elapse_app/screens/tournament_mode/widgets/ranking_overview_widget.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';

import '../../classes/Tournament/division.dart';

import 'package:elapse_app/classes/Miscellaneous/remote_config.dart';

class TMHomePage extends StatefulWidget {
  const TMHomePage(
      {super.key,
      required this.tournamentID,
      required this.teamID,
      required this.teamNumber});
  final int tournamentID;
  final int teamID;
  final String teamNumber;

  @override
  State<TMHomePage> createState() => _TMHomePageState();
}

class _TMHomePageState extends State<TMHomePage> {
  Tournament? _tournament;
  bool _isLoading = true;
  Division? _division;

  @override
  void initState() {
    super.initState();
    _initializeTournament();
  }

  Future<void> _initializeTournament({bool forceRefresh = false}) async {
    final cachedTournament = CacheManager.lastLoadedTournament;

    if (!forceRefresh && cachedTournament != null && cachedTournament.id == widget.tournamentID) {
      _setupWithTournament(cachedTournament);
    } else {
      // For forceRefresh (pull-to-refresh), use setState to show loading spinner
      // For initial load from initState, just assign directly
      if (forceRefresh) {
        setState(() {
          _isLoading = true;
        });
      } else {
        _isLoading = true;
      }
      try {
        final t = await TMTournamentDetails(widget.tournamentID, forceRefresh: forceRefresh);
        if (mounted) {
          _setupWithTournament(t);
          setState(() {});
        }
      } catch (error) {
        debugPrint('Failed to load tournament: $error');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _setupWithTournament(Tournament tournament) {
    _tournament = tournament;
    _isLoading = false;

    // Find the division that contains this team
    if (tournament.divisions.isNotEmpty) {
      _division = tournament.divisions.firstWhere(
        (d) => d.teamStats?.containsKey(widget.teamID) ?? false,
        orElse: () => tournament.divisions.first,
      );
    }
  }

  /// Get the current or upcoming session for leagues
  /// Returns null if not a league or no sessions available
  LeagueSession? _getCurrentSession() {
    if (_tournament == null || !_tournament!.isLeague) {
      return null;
    }
    
    // Guard for null or empty sessions
    if (_tournament!.sessions == null || _tournament!.sessions!.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Find today's session or the next upcoming session
    for (final session in _tournament!.sessions!) {
      final sessionDay = DateTime(session.date.year, session.date.month, session.date.day);
      if (sessionDay.isAtSameMomentAs(today) || sessionDay.isAfter(today)) {
        return session;
      }
    }

    // Fall back to last session if all sessions are in the past
    return _tournament!.sessions!.last;
  }

  /// Filter games by current session for leagues
  /// In tournament mode, we include unscheduled games since they may be
  /// matches pending scheduling for the current session
  List<Game> _filterGamesForCurrentSession(List<Game> games) {
    final session = _getCurrentSession();
    if (session == null) {
      return games;
    }

    return games.where((game) {
      // Include games scheduled for the current session
      if (game.scheduledTime != null) {
        return _isSameDay(game.scheduledTime!, session.date);
      }
      // Include unscheduled games in tournament mode
      // (they may be matches pending scheduling for this session)
      return true;
    }).toList();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Theme.of(context).colorScheme.surface,
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Icon(Icons.search,
                color: Theme.of(context).colorScheme.onSecondary),
          ),
          Text("Search your tournament",
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearchBarWithNavigation(BuildContext context) {
    if (_tournament == null || _division == null) {
      return _buildSearchBar(context);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) =>
                SearchScreen(tournament: _tournament!, division: _division!),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: _buildSearchBar(context),
    );
  }

  Widget _buildNextGameSection() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
            height: 50,
            width: 50,
            child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_tournament == null || _division == null || _division!.teamStats == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(18)),
              child: Text(
                "Tournament data is not available yet",
                style: TextStyle(fontSize: 16),
              )),
        ),
      );
    }

    if (_division!.games == null || _division!.games!.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(18)),
              child: Text(
                "No matches currently available",
                style: TextStyle(fontSize: 16),
              )),
        ),
      );
    }

    // Filter games by current session for leagues
    List<Game> sessionGames = _filterGamesForCurrentSession(_division!.games!);

    List<Game> upcomingGames = getTeamGames(sessionGames, widget.teamNumber).where(
      (element) {
        return element.startedTime == null &&
            element.redScore == 0 &&
            element.blueScore == 0;
      },
    ).toList();

    if (upcomingGames.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(18)),
              child: Text(
                "No matches currently available",
                style: TextStyle(fontSize: 16),
              )),
        ),
      );
    }

    Game game = upcomingGames[0];
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            NextGame(
              game: game,
              games: sessionGames,
              rankings: _division!.teamStats!,
              skills: _tournament!.tournamentSkills ?? {},
              targetTeam: TeamPreview(
                  teamNumber: widget.teamNumber,
                  teamID: widget.teamID),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingGamesSection() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
            height: 50,
            width: 50,
            child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_tournament == null || _division == null || _division!.teamStats == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(18)),
              child: Text(
                "No matches currently available",
                style: TextStyle(fontSize: 16),
              )),
        ),
      );
    }

    // Filter games by current session for leagues
    List<Game> sessionGames = _filterGamesForCurrentSession(_division!.games!);

    List<Game> upcomingGames = getTeamGames(sessionGames, widget.teamNumber).where(
      (element) {
        return element.startedTime == null &&
            element.redScore == 0 &&
            element.blueScore == 0;
      },
    ).toList();

    if (upcomingGames.length < 2) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 23),
          child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(18)),
              child: Text(
                "No upcoming matches",
                style: TextStyle(fontSize: 16),
              )),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            Game game = upcomingGames[index + 1];
            return Column(
              children: [
                GameWidget(
                  game: game,
                  teamName: widget.teamNumber,
                  isAllianceColoured: true,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  height: 3,
                )
              ],
            );
          },
          childCount: upcomingGames.length - 1,
        ),
      ),
    );
  }

  Widget _buildRankingOverviewSection() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: SizedBox(
            height: 50,
            width: 50,
            child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_tournament == null || _division == null || _division!.teamStats == null) {
      return const SliverToBoxAdapter(child: SizedBox(height: 50, width: 50));
    }

    if (_division!.teamStats!.isEmpty ||
        !_division!.teamStats!.containsKey(widget.teamID) ||
        (_tournament!.tournamentSkills?.isEmpty ?? true)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverToBoxAdapter(
        child: RankingOverviewWidget(
          teamStats: _division!.teamStats![widget.teamID]!,
          skills: _tournament!.tournamentSkills!,
          teamID: widget.teamID,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig = FirebaseRemoteConfigService();
    final showVDAWarn =
        !remoteConfig.getBool(FirebaseRemoteConfigKeys.vdaStatusKey);

    String welcomeMessage = "Good Afternoon";
    if (DateTime.now().hour < 12) {
      welcomeMessage = "Good Morning";
    } else if (DateTime.now().hour < 18) {
      welcomeMessage = "Good Afternoon";
    } else {
      welcomeMessage = "Good Evening";
    }
    String imageString =
        Theme.of(context).colorScheme.brightness == Brightness.dark
            ? "assets/dg4x.png"
            : "assets/lg4x.png";

    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        _initializeTournament(forceRefresh: true);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 190,
            centerTitle: false,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                double sizedBoxHeight = (top - kToolbarHeight) * 0.58 -
                    MediaQuery.of(context).viewPadding.top;
                sizedBoxHeight = sizedBoxHeight < 0 ? 0 : sizedBoxHeight;
                return FlexibleSpaceBar(
                  expandedTitleScale: 1.25,
                  collapseMode: CollapseMode.parallax,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: Column(
                      children: [
                        const Spacer(),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            
                            Text(
                              welcomeMessage,
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600),
                            ),
                            showVDAWarn
                                ? IconButton(
                                      splashRadius:2,
                                      icon: const Icon(Icons.sync_problem,
                                          size: 24,
                                          color: Color.fromRGBO(0, 0, 0, 1)),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18)),
                                                title: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Some experiences may be limited",
                                                        style: TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5),
                                                        child: Text(
                                                          "One of our data sources, vrc-data-analysis, isn't functioning properly right now. Some features may be temporarily unavailable.",
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                    ]),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .secondary),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    )
                                : Container(height: 1)
                          ],
                        ),
                        SizedBox(
                          height: sizedBoxHeight,
                        )
                      ],
                    ),
                  ),
                  centerTitle: false,
                  background: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 23, right: 12, bottom: 10, top: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Image(image: AssetImage(imageString), height: 25),
                              const Spacer(),
                              SettingsButton(),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildSearchBarWithNavigation(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          const RoundedTop(),
          _buildNextGameSection(),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Text("Upcoming",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 10,
            ),
          ),
          _buildUpcomingGamesSection(),
          SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          _buildRankingOverviewSection(),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
          SliverToBoxAdapter(
              child: Row(
            children: [
              TextButton(
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 23))),
                  child: Text(
                    "Exit Tournament Mode",
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  onPressed: () {
                    prefs.setBool("isTournamentMode", false);
                    clearLastLoadedTournament();
                    setupGateKey.currentState?.reloadApp();
                  }),
              Spacer(),
            ],
          )),
        ],
      ),
    ));
  }
}
