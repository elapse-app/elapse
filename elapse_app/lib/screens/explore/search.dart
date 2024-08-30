import 'dart:convert';

import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
import 'package:elapse_app/classes/Miscellaneous/recent_search.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/screens/explore/filters.dart';
import 'package:elapse_app/screens/team_screen/team_screen.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/team_widget.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:side_sheet/side_sheet.dart';
import 'package:elapse_app/main.dart';

class ExploreSearch extends StatefulWidget {
  const ExploreSearch({super.key});
  @override
  State<ExploreSearch> createState() => _ExploreSearchState();
}

class _ExploreSearchState extends State<ExploreSearch>
    with TickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  String searchQuery = "";
  int selectedIndex = 0;
  Future<List<TeamPreview>>? teamSearch;
  Future<TournamentList>? tournamentSearch;
  List<String> titles = ["Search for Something", "Teams", "Tournaments"];
  List<RecentTeamSearch> recentTeamSearches = [];
  List<RecentTournamentSearch> recentTournamentSearches = [];

  int currentPage = 1;
  double leftOpacity = 1;
  double rightOpacity = 1;

  ExploreSearchFilter filter = ExploreSearchFilter();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    List<String> recentTeamStrings =
        prefs.getStringList("recentTeamSearches") ?? <String>[];

    for (int i = recentTeamStrings.length - 1; i >= 0; i--) {
      var json = jsonDecode(recentTeamStrings[i]);
      recentTeamSearches.add(RecentTeamSearch(
        searchTerm: json["searchTerm"],
        teamID: json["teamID"],
      ));
    }

    List<String> recentTournamentStrings =
        prefs.getStringList("recentTournamentSearches") ?? <String>[];

    for (int i = recentTournamentStrings.length - 1; i >= 0; i--) {
      var json = jsonDecode(recentTournamentStrings[i]);
      recentTournamentSearches.add(RecentTournamentSearch(
        searchTerm: json["searchTerm"],
        tournamentID: json["tournamentID"],
      ));
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      searchQuery = query;
      teamSearch = fetchTeamPreview(searchQuery);
      tournamentSearch = getTournaments(searchQuery, filter);
      currentPage - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 165,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      num containerHeight = constraints.maxHeight;
                      return Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Spacer(),
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      flex: 1,
                                      child: IconButton(
                                          icon: const Icon(
                                            Icons.arrow_back,
                                            size: 24,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          })),
                                  Flexible(
                                    flex: 6,
                                    child: TextField(
                                      focusNode: _focusNode,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: _onSearchSubmitted,
                                      cursorColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      decoration: const InputDecoration(
                                          hintText:
                                              "Search teams or tournaments",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              if (constraints.maxHeight - 135 + 45 > 0)
                                Container(
                                  height: containerHeight > 130
                                      ? 45
                                      : containerHeight - 130 + 45,
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        flex: 3,
                                        child: FilterButton(
                                            0, constraints.maxHeight, "Teams"),
                                      ),
                                      Flexible(
                                        flex: 3,
                                        child: FilterButton(
                                            1,
                                            constraints.maxHeight,
                                            "Tournaments"),
                                      ),
                                      Flexible(
                                          flex: 1,
                                          child: containerHeight - 130 + 20 > 0
                                              ? IconButton(
                                                  constraints: BoxConstraints(),
                                                  icon: Icon(
                                                    Icons.filter_list_outlined,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(((constraints
                                                                            .maxHeight -
                                                                        110) /
                                                                    20) >
                                                                1
                                                            ? 1
                                                            : (constraints
                                                                        .maxHeight -
                                                                    110) /
                                                                20),
                                                  ),
                                                  onPressed: () async {
                                                    final result =
                                                        await exploreFilter(
                                                            context, filter);
                                                    setState(() {
                                                      filter = result;
                                                      tournamentSearch =
                                                          getTournaments(
                                                              searchQuery,
                                                              filter);
                                                    });
                                                  },
                                                )
                                              : Container())
                                    ],
                                  ),
                                )
                              else
                                const Spacer(),
                              const Spacer()
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              centerTitle: false,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverHeaderDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Stack(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.primary,
                      height: 60,
                    ),
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            titles[selectedIndex + 1],
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          selectedIndex == 1
                              ? FutureBuilder(
                                  future: tournamentSearch,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              if (currentPage - 1 != 0) {
                                                setState(
                                                  () {
                                                    currentPage -= 1;
                                                    tournamentSearch =
                                                        getTournaments(
                                                            searchQuery, filter,
                                                            page: currentPage);
                                                  },
                                                );
                                              }
                                            },
                                            onTapDown: (details) {
                                              setState(() {
                                                leftOpacity = 0.75;
                                              });
                                            },
                                            onTapUp: (details) {
                                              setState(() {
                                                leftOpacity = 1;
                                              });
                                            },
                                            onTapCancel: () {
                                              setState(() {
                                                leftOpacity = 1.0;
                                              });
                                            },
                                            child: AnimatedOpacity(
                                              opacity: leftOpacity,
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              child: Icon(
                                                Icons.arrow_back_ios_outlined,
                                                color: currentPage != 1
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(
                                                            rightOpacity)
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.5),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            "${currentPage.toString()}/${snapshot.data?.maxPage}",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (currentPage !=
                                                  snapshot.data?.maxPage) {
                                                setState(
                                                  () {
                                                    currentPage += 1;
                                                    tournamentSearch =
                                                        getTournaments(
                                                            searchQuery, filter,
                                                            page: currentPage);
                                                  },
                                                );
                                              }
                                            },
                                            onTapDown: (details) {
                                              setState(() {
                                                rightOpacity = 0.75;
                                              });
                                            },
                                            onTapUp: (details) {
                                              setState(() {
                                                rightOpacity = 1;
                                              });
                                            },
                                            onTapCancel: () {
                                              setState(() {
                                                rightOpacity = 1.0;
                                              });
                                            },
                                            child: AnimatedOpacity(
                                              opacity: rightOpacity,
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              child: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                color: currentPage !=
                                                        snapshot.data?.maxPage
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(
                                                            rightOpacity)
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.5),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_back_ios_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceDim,
                                            size: 20,
                                          ),
                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceDim,
                                            size: 20,
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                )
                              : Container()
                        ],
                      ),
                    ),
                  ],
                )),
          ),
          selectedIndex == 0 ? TeamSearchPage() : TournamentSearchPage(),
        ],
      ),
    );
  }

  SliverPadding TeamSearchPage() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverToBoxAdapter(
        child: FutureBuilder<List<TeamPreview>>(
          future: teamSearch,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data?.isEmpty ?? true) {
                return const BigErrorMessage(
                    icon: Icons.search_off_outlined, message: "No Teams Found");
              }
              final uniqueTeams = snapshot.data!.toSet().toList();
              return Column(
                children: uniqueTeams
                    .map((team) => Column(
                          children: [
                            TeamWidget(
                              teamNumber: team.teamNumber,
                              teamID: team.teamID,
                              teamName: team.teamName,
                              location: team.location,
                              saveSearch: true,
                              saveState: () {
                                setState(() {
                                  recentTeamSearches.add(RecentTeamSearch(
                                      searchTerm: team.teamNumber,
                                      teamID: team.teamID));
                                });
                              },
                            ),
                            Divider(
                              color: Theme.of(context).colorScheme.surfaceDim,
                            )
                          ],
                        ))
                    .toList(),
              );
            } else {
              if (recentTeamSearches.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: recentTeamSearches
                          .map((e) => GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TeamScreen(
                                        teamID: e.teamID,
                                        teamNumber: e.searchTerm,
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: 60,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.history_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            e.searchTerm,
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                      )
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 0, top: 10, right: 10, bottom: 10),
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      onPressed: () {
                        setState(() {
                          recentTeamSearches = [];
                          prefs.setStringList("recentTeamSearches", []);
                        });
                      },
                      child: Text(
                        "Clear Searches",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    )
                  ],
                );
              }
              return const Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.search_outlined,
                      size: 128,
                      weight: 0.1,
                    ),
                    Text("Search for a team"),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  SliverPadding TournamentSearchPage() {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 23),
      sliver: SliverToBoxAdapter(
        child: FutureBuilder(
          future: tournamentSearch,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              if (snapshot.data?.tournaments.isEmpty == true) {
                return const BigErrorMessage(
                    icon: Icons.search_off_outlined,
                    message: "No Tournaments Found");
              }
              List<TournamentPreview> tournaments =
                  snapshot.data?.tournaments ?? [];
              return Column(
                  children: tournaments
                      .map((e) => TournamentPreviewWidget(
                            tournamentPreview: e,
                            saveSearch: true,
                            saveState: () {
                              setState(() {
                                recentTournamentSearches.add(
                                    RecentTournamentSearch(
                                        searchTerm: e.name,
                                        tournamentID: e.id));
                              });
                            },
                          ))
                      .toList());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              if (recentTournamentSearches.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: recentTournamentSearches
                          .map((e) => GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TournamentScreen(
                                        tournamentID: e.tournamentID,
                                      ),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  height: 60,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.history_rounded,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: Text(
                                              e.searchTerm,
                                              style: TextStyle(
                                                fontSize: 18,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceDim,
                                      )
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 0, top: 10, right: 10, bottom: 10),
                          minimumSize: Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          alignment: Alignment.centerLeft),
                      onPressed: () {
                        setState(() {
                          recentTournamentSearches = [];
                          prefs.setStringList("recentTournamentSearches", []);
                        });
                      },
                      child: Text(
                        "Clear Searches",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                    )
                  ],
                );
              }
              return const Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    Icon(
                      Icons.search_outlined,
                      size: 128,
                      weight: 0.1,
                    ),
                    Text("Search for a tournament"),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget FilterButton(buttonIndex, maxHeight, text) {
    Color selectedContainerColor = Theme.of(context).colorScheme.primary;
    Color unselectedContainerColor = Theme.of(context).colorScheme.surface;

    BorderRadius borderRadius;

    if (buttonIndex == 0) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      );
    } else {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = buttonIndex;
          currentPage = 1;
        });
      },
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration:
            const Duration(milliseconds: 300), // Duration of the animation
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedIndex == buttonIndex
              ? selectedContainerColor.withOpacity(
                  ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)
              : unselectedContainerColor.withOpacity(
                  ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
          border: Border.all(
              width: 1.5,
              color: Theme.of(context).colorScheme.primary.withOpacity(
                  ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)),
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary.withOpacity(
                ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
