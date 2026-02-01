import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/league_session.dart';
import 'package:elapse_app/classes/Tournament/tournament_mode_functions.dart';
import 'package:intl/intl.dart';
import 'package:elapse_app/screens/tournament/pages/info/info.dart';
import 'package:elapse_app/screens/tournament/pages/main/search_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_filter.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/qualification_matches.dart';
import 'package:elapse_app/screens/tournament/pages/skills/skills.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import '../../../../classes/Filters/gradeLevel.dart';
import '../../../../classes/Filters/season.dart';
import '../../../../classes/Team/vdaStats.dart';
import '../../../../classes/Team/world_skills.dart';

class TournamentLoadedScreen extends StatefulWidget {
  final int tournamentId;
  final bool isPreview;
  const TournamentLoadedScreen({
    super.key,
    required this.tournamentId,
    this.isPreview = false,
  });

  @override
  State<TournamentLoadedScreen> createState() => _TournamentLoadedScreenState();
}

class _TournamentLoadedScreenState extends State<TournamentLoadedScreen> {
  late Tournament tournament; // mutable tournament so refreshes propagate across the screen
  late int selectedIndex;
  int sortIndex = 0;
  List<String> titles = ["Schedule", "Rankings", "Skills", "Info"];
  List<String> rankingSorts = ["Rank", "AP", "SP", "AWP", "OPR", "DPR", "CCWM", "Skills", "World Skills", "TrueSkill"];
  List<String> skillsSorts = ["Rank", "Driver", "Auton", "Driver Attempts", "Auton Attempts"];
  TournamentRankingsFilter filter = TournamentRankingsFilter();

  bool showPractice = true;
  bool showQualification = true;
  bool showElimination = true;

  final FocusNode _focusNode = FocusNode();

  late Division division;
  late bool inSearch;
  late String searchQuery;
  late String savedQuery;
  late ScrollController _scrollController;

  List<Team> rankingsTeams = [];
  List<TeamPreview> savedTeams = [];
  bool useSavedTeams = false;

  List<Game> practice = [];
  List<Game> qualifications = [];
  List<Game> eliminations = [];

  LeagueSession? _selectedSession; // null = show all sessions (for leagues)

  List<Widget> widgets = [SliverToBoxAdapter(), SliverToBoxAdapter()];

  late Future<List<WorldSkillsStats>> worldSkillsStats;
  late Future<List<VDAStats>> vdaStats;

  void savedPress() {
    setState(() {
      useSavedTeams = !useSavedTeams;
      if (useSavedTeams) {
        final String savedTeam = prefs.getString("savedTeam") ?? "";
        TeamPreview savedTeamPreview =
            TeamPreview(teamID: jsonDecode(savedTeam)["teamID"], teamNumber: jsonDecode(savedTeam)["teamNumber"]);
        List<String> savedTeamsString = prefs.getStringList("savedTeams") ?? [];
        savedTeams.add(savedTeamPreview);
        savedTeams.addAll(savedTeamsString
            .map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"]))
            .toList());
        rankingsTeams =
            tournament.teams.where((element) => savedTeams.any((element2) => element2.teamID == element.id)).toList();
      } else {
        rankingsTeams = tournament.teams;
      }
    });
  }

  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controller early to prevent LateInitializationError in dispose()
    // if user navigates away during async loading
    _scrollController = ScrollController();
    _initializeTournament();
  }

  /// Initialize tournament data - try sync cache first, fall back to async DB fetch
  Future<void> _initializeTournament({bool forceRefresh = false}) async {
    // Try sync access first - cache should be set by entry point's TMTournamentDetails call
    final cachedTournament = getLastLoadedTournament();

    // Verify cached tournament ID matches to avoid race conditions when navigating between tournaments
    if (!forceRefresh && cachedTournament != null && cachedTournament.id == widget.tournamentId) {
      _setupWithTournament(cachedTournament);
    } else {
      // Cache not set - fetch from DB asynchronously
      // This handles edge cases like hot restart or direct navigation
      if (forceRefresh) {
        setState(() {
          _isLoading = true;
          _loadError = null;
        });
      } else {
        _isLoading = true;
      }

      try {
        final t = await TMTournamentDetails(widget.tournamentId, forceRefresh: forceRefresh);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _setupWithTournament(t);
          });
        }
      } catch (error, stackTrace) {
        // Log error for debugging
        debugPrint('TournamentLoadedScreen: Failed to load tournament: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadError = 'Failed to load tournament';
          });
        }
      }
    }
  }

  /// Set up all state from the tournament object
  void _setupWithTournament(Tournament t) {
    tournament = t;
    rankingsTeams = tournament.teams;

    // Safely access first division with bounds check
    if (tournament.divisions.isNotEmpty) {
      division = tournament.divisions[0];
    } else {
      // This shouldn't happen in practice, but handle gracefully
      division = Division(id: 0, name: 'Unknown', order: 1);
    }

    inSearch = false;
    searchQuery = "";
    savedQuery = "";

    worldSkillsStats = getWorldSkillsRankings(tournament.seasonID, getGradeLevel(prefs.getString("defaultGrade")));
    vdaStats = getTrueSkillData(tournament.seasonID);

    // Process games once on init, not every build
    _processGames();

    // Determine initial tab based on whether games exist
    if (division.games == null || division.games!.isEmpty) {
      selectedIndex = 3; // Info tab
    } else {
      selectedIndex = 0; // Schedule tab
    }
  }

  /// Process game lists once when data loads or division changes, not on every build
  void _processGames() {
    if (division.games != null && division.games!.isNotEmpty) {
      adjustMatchTiming(division.games!);

      // Filter games by selected session (for leagues)
      List<Game> filteredGames = _filterGamesBySession(division.games!);

      practice = filteredGames.where((game) => game.roundNum == 1).toList();
      qualifications = filteredGames.where((game) => game.roundNum == 2).toList();
      eliminations = filteredGames.where((game) => game.roundNum > 2).toList();

      // For leagues showing all sessions, sort by scheduled time first to group by session date
      if (tournament.isLeague && _selectedSession == null) {
        _sortGamesByScheduledTime(practice);
        _sortGamesByScheduledTime(qualifications);
        _sortGamesByScheduledTime(eliminations);
      }
    } else {
      practice = [];
      qualifications = [];
      eliminations = [];
    }
  }

  /// Sort games by scheduled time first, then by game number
  /// This ensures games from the same session/date stay grouped together
  void _sortGamesByScheduledTime(List<Game> games) {
    games.sort((a, b) {
      // First sort by scheduled date (null dates go to the end)
      if (a.scheduledTime != null && b.scheduledTime != null) {
        final dateCompare = a.scheduledTime!.compareTo(b.scheduledTime!);
        if (dateCompare != 0) return dateCompare;
      } else if (a.scheduledTime != null) {
        return -1; // a has date, b doesn't - a comes first
      } else if (b.scheduledTime != null) {
        return 1; // b has date, a doesn't - b comes first
      }
      // Then sort by game number within the same date
      return a.gameNum.compareTo(b.gameNum);
    });
  }

  /// Filter games by selected session date (for leagues)
  List<Game> _filterGamesBySession(List<Game> games) {
    // If no session selected, not a league, or single-session league, show all games
    if (_selectedSession == null ||
        !tournament.isLeague ||
        tournament.sessions == null ||
        tournament.sessions!.length <= 1) {
      return games;
    }

    return games.where((game) {
      // Include games scheduled for the selected session
      if (game.scheduledTime != null) {
        return _isSameDay(game.scheduledTime!, _selectedSession!.date);
      }
      // Include unscheduled games in session view as well
      // (they may be matches pending scheduling for this session)
      return true;
    }).toList();
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Builds the session dropdown for leagues (returns empty widget for tournaments)
  Widget _buildSessionDropdown() {
    // Only show for leagues with multiple sessions
    // Single-session leagues display like standard tournaments (no dropdown)
    if (!tournament.isLeague || tournament.sessions == null || tournament.sessions!.length <= 1) {
      return const SizedBox.shrink();
    }

    return DropdownButton<LeagueSession?>(
      value: _selectedSession,
      borderRadius: BorderRadius.circular(20),
      hint: Row(
        children: [
          const Icon(Icons.calendar_today, size: 24),
          const SizedBox(width: 10),
          Text("All"),
        ],
      ),
      items: [
        DropdownMenuItem<LeagueSession?>(
          value: null,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 24),
              const SizedBox(width: 10),
              Text("All"),
            ],
          ),
        ),
        ...tournament.sessions!.map<DropdownMenuItem<LeagueSession?>>((session) {
          return DropdownMenuItem(
            value: session,
            child: Row(
              children: [
                const Icon(Icons.event, size: 24),
                const SizedBox(width: 10),
                Text(DateFormat('MMM d').format(session.date)),
              ],
            ),
          );
        }),
      ],
      onChanged: (LeagueSession? value) {
        setState(() {
          _selectedSession = value;
          _processGames();
        });
      },
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Lazily builds only the currently selected page - avoids instantiating all 4 pages every build
  Widget _buildCurrentPage() {
    switch (selectedIndex) {
      case 0:
        // Schedule content is handled separately via SliverStickyHeader widgets
        return const SliverToBoxAdapter();
      case 1:
        // Handle null skills data
        if (tournament.tournamentSkills == null) {
          return const SliverToBoxAdapter(
              child: BigErrorMessage(icon: Icons.list_outlined, message: "Rankings not available"));
        }
        // Rankings page with caching check
        final gradeLevel = getGradeLevel(prefs.getString("defaultGrade"));
        final seasonId =
            gradeLevel == gradeLevels["College"] ? (seasons[0].vexUId ?? seasons[0].vrcId) : seasons[0].vrcId;
        final worldSkillsData = prefs.getString("worldSkillsData");
        final vdaData = prefs.getString("vdaData");

        if (hasCachedWorldSkillsRankings(seasonId, gradeLevel) &&
            hasCachedTrueSkillData() &&
            worldSkillsData != null &&
            vdaData != null) {
          return RankingsPage(
            searchQuery: searchQuery,
            sort: rankingSorts[sortIndex],
            divisionIndex: division.order - 1,
            filter: filter,
            skills: tournament.tournamentSkills!,
            worldSkills:
                jsonDecode(worldSkillsData).map<WorldSkillsStats>((e) => WorldSkillsStats.fromJson(e)).toList(),
            vda: jsonDecode(vdaData).map<VDAStats>((json) => VDAStats.fromJson(json)).toList(),
          );
        }
        return FutureBuilder(
          future: Future.wait(sortIndex == 9 ? [worldSkillsStats, vdaStats] : [worldSkillsStats]),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return const SliverToBoxAdapter(child: LinearProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                      child: BigErrorMessage(icon: Icons.list_outlined, message: "Unable to load rankings"));
                }
                return RankingsPage(
                  searchQuery: searchQuery,
                  sort: rankingSorts[sortIndex],
                  divisionIndex: division.order - 1,
                  filter: filter,
                  skills: tournament.tournamentSkills!,
                  worldSkills: snapshot.data?[0] as List<WorldSkillsStats>,
                  vda: sortIndex == 9 ? (snapshot.data?[1] as List<VDAStats>) : null,
                );
            }
          },
        );
      case 2:
        // Handle null skills data
        if (tournament.tournamentSkills == null) {
          return const SliverToBoxAdapter(
              child: BigErrorMessage(icon: Icons.sports_esports_outlined, message: "Skills not available"));
        }
        return SkillsPage(
          skills: tournament.tournamentSkills!,
          teams: tournament.teams,
          divisions: tournament.divisions,
          sort: sortIndex,
          filter: filter,
        );
      case 3:
        return InfoPage(
          tournament: tournament,
          awards: tournament.awards,
        );
      default:
        return const SliverToBoxAdapter();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle loading state (async fallback when cache was empty)
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Handle error state
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(_loadError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      );
    }

    // Game lists are now computed once in _processGames() called from initState
    // and when division changes, not on every build

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: RefreshIndicator(
          onRefresh: () async {
            // Use TMTournamentDetails with forceRefresh to fetch fresh data from API
            // This fetches from API, saves to SQLite, and updates the in-memory CacheManager
            // Note: RefreshIndicator shows its own spinner, but we could optionally set _isLoading here
            final updatedTournament = await TMTournamentDetails(widget.tournamentId, forceRefresh: true);

            // Preserve the user's current division and session selection
            final currentDivisionId = division.id;
            final currentSessionDate = _selectedSession?.date;

            setState(() {
              tournament = updatedTournament;

              // Find the same division in the updated tournament, or fall back to first division
              if (tournament.divisions.isNotEmpty) {
                division = tournament.divisions.firstWhere(
                  (d) => d.id == currentDivisionId,
                  orElse: () => tournament.divisions[0],
                );
              }

              // Preserve session selection for leagues with multiple sessions
              if (currentSessionDate != null &&
                  tournament.isLeague &&
                  tournament.sessions != null &&
                  tournament.sessions!.length > 1) {
                _selectedSession = tournament.sessions!.firstWhere(
                  (s) => _isSameDay(s.date, currentSessionDate),
                  orElse: () => tournament.sessions!.first,
                );
              } else {
                _selectedSession = null;
              }

              rankingsTeams = tournament.teams;
              inSearch = false;
              searchQuery = "";
              savedQuery = "";

              worldSkillsStats =
                  getWorldSkillsRankings(tournament.seasonID, getGradeLevel(prefs.getString("defaultGrade")));
              vdaStats = getTrueSkillData(tournament.seasonID);

              // Recompute game lists after refresh
              _processGames();
            });
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              ElapseAppBar(
                showVDAWarning: false,
                title: Row(
                  children: [
                    Text(
                      titles[selectedIndex],
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    GestureDetector(
                      child: const Icon(
                        Icons.search,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 300),
                            reverseTransitionDuration: Duration(milliseconds: 300),
                            pageBuilder: (context, animation, secondaryAnimation) => SearchScreen(
                              tournament: tournament,
                              division: division,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              // Create a Tween that transitions the new screen from fully transparent to fully opaque
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 18),
                  ],
                ),
                backNavigation: widget.isPreview,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 23, right: 12, bottom: 20, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.isPreview
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                                  ),
                                  Spacer(),
                                  _buildSessionDropdown(),
                                  tournament.divisions.length > 1
                                      ? DropdownButton<Division>(
                                          value: division,
                                          borderRadius: BorderRadius.circular(20),
                                          items: tournament.divisions.map<DropdownMenuItem<Division>>((division) {
                                            return DropdownMenuItem(
                                                value: division,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.groups_3_outlined,
                                                      size: 30,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(division.name),
                                                  ],
                                                ));
                                          }).toList(),
                                          onChanged: (Division? value) {
                                            if (value != null && value != division) {
                                              setState(() {
                                                division = value;
                                                _processGames();
                                              });
                                            }
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  DropdownButton<Division>(
                                    value: division,
                                    borderRadius: BorderRadius.circular(20),
                                    items: tournament.divisions.map<DropdownMenuItem<Division>>((division) {
                                      return DropdownMenuItem(
                                          value: division,
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.groups_3_outlined,
                                                size: 30,
                                              ),
                                              SizedBox(width: 10),
                                              Text(division.name),
                                            ],
                                          ));
                                    }).toList(),
                                    onChanged: (Division? value) {
                                      if (value != null && value != division) {
                                        setState(() {
                                          division = value;
                                          _processGames();
                                        });
                                      }
                                    },
                                  ),
                                  _buildSessionDropdown(),
                                  Spacer(),
                                  SettingsButton()
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              // SliverAppBar.large(
              //   automaticallyImplyLeading: false,
              //   expandedHeight: 125,
              //   centerTitle: false,
              //   flexibleSpace: FlexibleSpaceBar(
              //     expandedTitleScale: 1,
              //     collapseMode: CollapseMode.parallax,
              //     title: Padding(
              //       padding: const EdgeInsets.only(left: 20.0, right: 12.0),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.end,
              //         children: [
              //           widget.isPreview
              //               ? IconButton(
              //                   padding: const EdgeInsets.only(top: 10),
              //                   constraints: BoxConstraints(),
              //                   icon: const Icon(Icons.arrow_back),
              //                   onPressed: () {
              //                     Navigator.pop(context);
              //                   },
              //                 )
              //               : Container(),
              //           Text(
              //             titles[selectedIndex],
              //             style: const TextStyle(
              //                 fontSize: 30, fontWeight: FontWeight.w600),
              //           ),
              //           Spacer(),
              //           IconButton(
              //             icon: const Icon(
              //               Icons.search,
              //               size: 30,
              //             ),
              //             onPressed: () {
              //               Navigator.push(
              //                 context,
              //                 PageRouteBuilder(
              //                   transitionDuration: Duration(milliseconds: 300),
              //                   reverseTransitionDuration:
              //                       Duration(milliseconds: 300),
              //                   pageBuilder:
              //                       (context, animation, secondaryAnimation) =>
              //                           SearchScreen(
              //                     tournament: widget.tournament,
              //                     division: division,
              //                   ),
              //                   transitionsBuilder: (context, animation,
              //                       secondaryAnimation, child) {
              //                     // Create a Tween that transitions the new screen from fully transparent to fully opaque
              //                     return FadeTransition(
              //                       opacity: animation,
              //                       child: child,
              //                     );
              //                   },
              //                 ),
              //               );
              //             },
              //           ),
              //         ],
              //       ),
              //     ),
              //     centerTitle: false,
              //     background: SafeArea(
              //       child: Padding(
              //         padding:
              //             const EdgeInsets.only(left: 20, right: 12, bottom: 20),
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 DropdownButton<Division>(
              //                   value: division,
              //                   borderRadius: BorderRadius.circular(20),
              //                   items: widget.tournament.divisions
              //                       .map<DropdownMenuItem<Division>>((division) {
              //                     return DropdownMenuItem(
              //                         value: division,
              //                         child: Row(
              //                           children: [
              //                             const Icon(
              //                               Icons.groups_3_outlined,
              //                               size: 30,
              //                             ),
              //                             SizedBox(width: 10),
              //                             Text(division.name),
              //                           ],
              //                         ));
              //                   }).toList(),
              //                   onChanged: (Division? value) => {
              //                     setState(() {
              //                       division = value!;
              //                       selectedIndex = selectedIndex;
              //                     })
              //                   },
              //                 ),
              //                 const Spacer(),
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              //   backgroundColor: Theme.of(context).colorScheme.primary,
              // ),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverHeaderDelegate(
                  minHeight: 70.0,
                  maxHeight: 70.0,
                  child: Stack(
                    children: [
                      Container(height: 300, color: Theme.of(context).colorScheme.primary),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildIconButton(context, Icons.schedule, 0),
                              _buildIconButton(context, Icons.format_list_numbered_outlined, 1),
                              _buildIconButton(context, Icons.sports_esports_outlined, 2),
                              _buildIconButton(context, Icons.info_outlined, 3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // selectedIndex == 0 && division.teamStats?.isNotEmpty == true
              //     ? SliverPersistentHeader(
              //         pinned: true,
              //         delegate: SliverHeaderDelegate(
              //           maxHeight: 40,
              //           minHeight: 40,
              //           child: Container(
              //             alignment: Alignment.topCenter,
              //             padding: EdgeInsets.only(
              //                 left: 23, right: 23, bottom: 10, top: 5),
              //             color: Theme.of(context).colorScheme.surface,
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Text(
              //                   "Enable Live Timing",
              //                   style: TextStyle(fontSize: 16),
              //                 ),
              //                 Switch(
              //                   value: useLiveTiming,
              //                   onChanged: (bool value) {
              //                     setState(() {
              //                       useLiveTiming = value;
              //                     });
              //                   },
              //                 )
              //               ],
              //             ),
              //           ),
              //         ),
              //       )
              //     : SliverToBoxAdapter(),
              selectedIndex == 1 && division.teamStats?.isNotEmpty == true
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 23),
                        height: 50,
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 6,
                              child: _RankingsChipListWithFade(
                                labels: rankingSorts,
                                selectedIndex: sortIndex,
                                vdaStats: vdaStats,
                                onSelected: (index) {
                                  setState(() {
                                    sortIndex = index;
                                  });
                                },
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: IconButton(
                                    icon: const Icon(
                                      Icons.filter_list,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      TournamentRankingsFilter updatedFilter = await worldRankingsFilter(
                                        context,
                                        filter,
                                        prefs.getBool("isTournamentMode") ?? false,
                                      );
                                      setState(() {
                                        filter = updatedFilter;
                                      });
                                    })),
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(),
              selectedIndex == 2
                  ? SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.only(left: 23),
                        height: 50,
                        child: Flex(
                          direction: Axis.horizontal,
                          children: [
                            Flexible(
                              flex: 6,
                              child: _ChipListWithFade(
                                labels: skillsSorts,
                                selectedIndex: sortIndex,
                                onSelected: (index) {
                                  setState(() {
                                    sortIndex = index;
                                  });
                                },
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: IconButton(
                                    icon: const Icon(
                                      Icons.filter_list,
                                      size: 30,
                                    ),
                                    onPressed: () async {
                                      TournamentRankingsFilter updatedFilter = await worldRankingsFilter(
                                        context,
                                        filter,
                                        prefs.getBool("isTournamentMode") ?? false,
                                      );
                                      setState(() {
                                        filter = updatedFilter;
                                      });
                                    })),
                          ],
                        ),
                      ),
                    )
                  : const SliverToBoxAdapter(),
              // selectedIndex == 0 &&
              //         division.games != null &&
              //         division.games!.isNotEmpty &&
              //         division.games!.any(
              //           (element) {
              //             return element.roundNum == 1;
              //           },
              //         )
              //     ? SliverPersistentHeader(
              //         pinned: true,
              //         delegate: SliverHeaderDelegate(
              //           child: Container(
              //             color: Theme.of(context).colorScheme.surface,
              //             padding:
              //                 EdgeInsets.symmetric(horizontal: 23, vertical: 5),
              //             child: Row(
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               children: [
              //                 Text(
              //                   "Practice",
              //                   style: TextStyle(fontSize: 24),
              //                 ),
              //                 IconButton(
              //                   focusColor: Colors.transparent,
              //                   splashColor: Colors.transparent,
              //                   highlightColor: Colors.transparent,
              //                   onPressed: () {
              //                     setState(() {
              //                       showPractice = !showPractice;
              //                     });
              //                   },
              //                   icon: Icon(showPractice
              //                       ? Icons.keyboard_arrow_down
              //                       : Icons.keyboard_arrow_right),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           maxHeight: 40,
              //           minHeight: 40,
              //         ),
              //       )
              //     : SliverToBoxAdapter(),
              // selectedIndex == 0 &&
              //         division.games != null &&
              //         division.games!.isNotEmpty
              //     ? SliverPersistentHeader(
              //         pinned: true,
              //         delegate: SliverHeaderDelegate(
              //           child: Container(
              //             color: Theme.of(context).colorScheme.surface,
              //             padding:
              //                 EdgeInsets.symmetric(horizontal: 23, vertical: 5),
              //             child: Row(
              //               crossAxisAlignment: CrossAxisAlignment.center,
              //               children: [
              //                 Text(
              //                   "Qualification",
              //                   style: TextStyle(fontSize: 24),
              //                 ),
              //                 IconButton(
              //                   focusColor: Colors.transparent,
              //                   splashColor: Colors.transparent,
              //                   highlightColor: Colors.transparent,
              //                   onPressed: () {
              //                     setState(() {
              //                       showQualification = !showQualification;
              //                     });
              //                   },
              //                   icon: Icon(showQualification
              //                       ? Icons.keyboard_arrow_down
              //                       : Icons.keyboard_arrow_right),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           maxHeight: 40,
              //           minHeight: 40,
              //         ),
              //       )
              //     : SliverToBoxAdapter(),

              // showQualification ? pages[selectedIndex] : SliverToBoxAdapter(),
              selectedIndex == 0 && practice.isNotEmpty
                  ? SliverStickyHeader(
                      header: ScheduleTab(Theme.of(context).colorScheme.surface, "Practice", () {
                        setState(() {
                          showPractice = !showPractice;
                        });
                      }, showPractice),
                      sliver: showPractice ? MatchesView(games: practice) : SliverToBoxAdapter(),
                    )
                  : SliverToBoxAdapter(),

              selectedIndex == 0 && qualifications.isNotEmpty
                  ? SliverStickyHeader(
                      overlapsContent: false,
                      header: ScheduleTab(Theme.of(context).colorScheme.surface, "Qualifications", () {
                        setState(() {
                          showQualification = !showQualification;
                        });
                      }, showQualification),
                      sliver: showQualification ? MatchesView(games: qualifications) : SliverToBoxAdapter(),
                    )
                  : SliverToBoxAdapter(),

              selectedIndex == 0 && eliminations.isNotEmpty
                  ? SliverStickyHeader(
                      header: ScheduleTab(Theme.of(context).colorScheme.surface, "Eliminations", () {
                        setState(() {
                          showElimination = !showElimination;
                        });
                      }, showElimination),
                      sliver: showElimination ? MatchesView(games: eliminations) : SliverToBoxAdapter(),
                    )
                  : SliverToBoxAdapter(),

              selectedIndex == 0 && (division.games == null || division.games!.isEmpty)
                  ? SliverToBoxAdapter(
                      child: BigErrorMessage(icon: Icons.schedule, message: "Schedule Not Available"),
                    )
                  : SliverToBoxAdapter(),

              _buildCurrentPage(),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                ),
              )
            ],
          ),
        ));
  }

  Widget ScheduleTab(Color backgroundColor, String title, void Function() onTap, bool variable) {
    return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          color: backgroundColor,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 24),
                  ),
                  Icon(variable ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right),
                ],
              )),
        ));
  }

  Widget _buildIconButton(BuildContext context, IconData icon, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                selectedIndex == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          ),
        ),
        IconButton(
          highlightColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () {
            setState(() {
              selectedIndex = index;
              sortIndex = 0;
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutExpo,
              );
            });
          },
        ),
      ],
    );
  }
}

/// A horizontal scrolling chip list with fade gradient on edges.
/// Manages its own fade state so scroll updates don't rebuild parent.
class _ChipListWithFade extends StatefulWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ChipListWithFade({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<_ChipListWithFade> createState() => _ChipListWithFadeState();
}

class _ChipListWithFadeState extends State<_ChipListWithFade> {
  double _fadeStart = 0;
  double _fadeEnd = 1;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        setState(() {
          _fadeStart = (scrollNotification.metrics.pixels / 10).clamp(0.0, 1.0);
          _fadeEnd =
              ((scrollNotification.metrics.maxScrollExtent - scrollNotification.metrics.pixels) / 10).clamp(0.0, 1.0);
        });
        return true;
      },
      child: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.generate(widget.labels.length, (int index) {
              return Container(
                padding: const EdgeInsets.only(right: 5),
                child: ChoiceChip(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  label: Text(
                    widget.labels[index],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  selected: widget.selectedIndex == index,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  disabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  chipAnimationStyle: ChipAnimationStyle(
                    enableAnimation: AnimationStyle(duration: Duration.zero),
                    selectAnimation: AnimationStyle(duration: Duration.zero),
                  ),
                  onSelected: (bool selected) => widget.onSelected(index),
                ),
              );
            }).toList(),
          ),
          IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                    Theme.of(context).colorScheme.surface,
                  ],
                  stops: [0.0, 0.05 * _fadeStart, 1 - 0.05 * _fadeEnd, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rankings chip list with special handling for TrueSkill (index 9) loading state.
class _RankingsChipListWithFade extends StatefulWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final Future<List<VDAStats>> vdaStats;

  const _RankingsChipListWithFade({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.vdaStats,
  });

  @override
  State<_RankingsChipListWithFade> createState() => _RankingsChipListWithFadeState();
}

class _RankingsChipListWithFadeState extends State<_RankingsChipListWithFade> {
  double _fadeStart = 0;
  double _fadeEnd = 1;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        setState(() {
          _fadeStart = (scrollNotification.metrics.pixels / 10).clamp(0.0, 1.0);
          _fadeEnd =
              ((scrollNotification.metrics.maxScrollExtent - scrollNotification.metrics.pixels) / 10).clamp(0.0, 1.0);
        });
        return true;
      },
      child: Stack(
        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            children: List<Widget>.generate(widget.labels.length, (int index) {
              // Index 9 (TrueSkill) has special loading state handling
              if (index == 9) {
                return FutureBuilder(
                  future: widget.vdaStats,
                  builder: (context, snapshot) {
                    final isLoaded = snapshot.connectionState == ConnectionState.done;
                    return Container(
                      padding: const EdgeInsets.only(right: 5),
                      child: ChoiceChip(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        label: Text(
                          widget.labels[index],
                          style: TextStyle(
                            color: isLoaded
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        selected: widget.selectedIndex == index,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: isLoaded
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.tertiary,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        selectedColor: Theme.of(context).colorScheme.primary,
                        chipAnimationStyle: ChipAnimationStyle(
                          enableAnimation: AnimationStyle(duration: Duration.zero),
                          selectAnimation: AnimationStyle(duration: Duration.zero),
                        ),
                        onSelected: isLoaded ? (bool selected) => widget.onSelected(index) : null,
                      ),
                    );
                  },
                );
              }
              return Container(
                padding: const EdgeInsets.only(right: 5),
                child: ChoiceChip(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  label: Text(
                    widget.labels[index],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  selected: widget.selectedIndex == index,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  disabledColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  chipAnimationStyle: ChipAnimationStyle(
                    enableAnimation: AnimationStyle(duration: Duration.zero),
                    selectAnimation: AnimationStyle(duration: Duration.zero),
                  ),
                  onSelected: (bool selected) => widget.onSelected(index),
                ),
              );
            }).toList(),
          ),
          IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                    Theme.of(context).colorScheme.surface.withValues(alpha: 0),
                    Theme.of(context).colorScheme.surface,
                  ],
                  stops: [0.0, 0.05 * _fadeStart, 1 - 0.05 * _fadeEnd, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
