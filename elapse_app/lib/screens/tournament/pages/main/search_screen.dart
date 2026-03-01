import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.tournamentId, required this.divisionId});

  final int tournamentId;
  final int divisionId;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  int selectedIndex = 0;
  String searchQuery = "";
  Tournament? _tournament;
  Division? _division;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournament();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _loadTournament() async {
    final tournament = await getTournamentFromCache(widget.tournamentId);
    if (tournament != null && mounted) {
      _tournament = tournament;
      for (final division in tournament.divisions) {
        if (division.id == widget.divisionId) {
          _division = division;
          break;
        }
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _tournament == null || _division == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<Team> filteredTeams = _tournament!.teams.where((e) {
      return (e.teamName!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              e.teamNumber!.toLowerCase().contains(searchQuery.toLowerCase())) &&
          ((_division!.teamStats != null && _division!.teamStats![e.id] != null) ||
              _division!.teamStats?.isEmpty == true);
    }).toList();
    List<Game> filteredGames;

    if (filteredTeams.length > 10) {
      filteredGames = [];
    } else {
      Set<String> teamNumbers = filteredTeams.map((e) => e.teamNumber!).toSet();

      filteredGames = _division!.games!.where((e) {
        if (searchQuery.isEmpty) {
          return true;
        }
        final blue = e.blueAlliancePreview ?? [];
        final red = e.redAlliancePreview ?? [];
        final query = searchQuery.toUpperCase();

        bool gameContainsSearchQuery = (blue.isNotEmpty && blue[0].teamNumber.contains(query)) ||
            (blue.length > 1 && blue[1].teamNumber.contains(query)) ||
            (red.isNotEmpty && red[0].teamNumber.contains(query)) ||
            (red.length > 1 && red[1].teamNumber.contains(query)) ||
            e.gameName.contains(query);

        bool gameContainsFilteredTeam = (blue.isNotEmpty && teamNumbers.contains(blue[0].teamNumber)) ||
            (blue.length > 1 && teamNumbers.contains(blue[1].teamNumber)) ||
            (red.isNotEmpty && teamNumbers.contains(red[0].teamNumber)) ||
            (red.length > 1 && teamNumbers.contains(red[1].teamNumber));

        return gameContainsSearchQuery || gameContainsFilteredTeam;
      }).toList();
    }
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
                            children: [
                              Spacer(),
                              Flex(
                                direction: Axis.horizontal,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        },
                                      )),
                                  Flexible(
                                    flex: 6,
                                    child: TextField(
                                      focusNode: _focusNode,
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                      },
                                      cursorColor: Theme.of(context).colorScheme.secondary,
                                      decoration: InputDecoration(
                                          hintText: "Search ${_division!.name}", border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              if (constraints.maxHeight - 135 + 45 > 0)
                                Container(
                                  height: containerHeight > 130 ? 45 : containerHeight - 130 + 45,
                                  child: Flex(
                                    direction: Axis.horizontal,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: FilterButton(0, constraints.maxHeight, "All"),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: FilterButton(1, constraints.maxHeight, "Teams"),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: FilterButton(2, constraints.maxHeight, "Games"),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Spacer(),
                              Spacer()
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
                minHeight: 25,
                maxHeight: 25,
                child: Hero(
                  tag: "top",
                  child: Stack(
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.primary,
                        height: 25,
                      ),
                      Container(
                        height: 25,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          selectedIndex == 0 || selectedIndex == 1
              ? SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 23.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('"$searchQuery" in teams', style: TextStyle(fontSize: 16)),
                        Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          thickness: 1.5,
                        )
                      ],
                    ),
                  ),
                )
              : const SliverToBoxAdapter(),
          selectedIndex == 0 || selectedIndex == 1
              ? filteredTeams.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final team = filteredTeams[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 23.0),
                            child: Column(
                              children: [
                                _division!.teamStats![team.id] == null
                                    ? EmptyRanking(
                                        teamName: team.teamNumber ?? "",
                                        teamID: team.id,
                                        allianceColor: Theme.of(context).colorScheme.onSurface)
                                    : RankingsWidget(
                                        teamNumber: team.teamNumber!,
                                        teamName: team.teamName!,
                                        teamID: team.id,
                                        stats: _division!.teamStats![team.id]!,
                                        allianceColor: Theme.of(context).colorScheme.onSurface,
                                      ),
                                index != filteredTeams.length - 1
                                    ? Divider(
                                        height: 3,
                                        color: Theme.of(context).colorScheme.surfaceDim,
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        },
                        childCount: filteredTeams.length,
                      ),
                    )
                  : const SliverToBoxAdapter(
                      child: SizedBox(height: 15, child: Center(child: Text("No results found"))))
              : const SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: selectedIndex == 0
                ? const SizedBox(
                    height: 15,
                  )
                : null,
          ),
          selectedIndex == 0 || selectedIndex == 2
              ? SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 23.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('"$searchQuery" in games', style: TextStyle(fontSize: 16)),
                        Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          thickness: 1.5,
                        )
                      ],
                    ),
                  ),
                )
              : SliverToBoxAdapter(),
          selectedIndex == 0 || selectedIndex == 2
              ? filteredGames.isNotEmpty
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final game = filteredGames[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 23.0),
                            child: Column(
                              children: [
                                GameWidget(
                                  game: game,
                                ),
                                index != _division!.games!.length - 1
                                    ? Divider(
                                        height: 3,
                                        color: Theme.of(context).colorScheme.surfaceDim,
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        },
                        childCount: filteredGames.length,
                      ),
                    )
                  : const SliverToBoxAdapter(
                      child: SizedBox(height: 15, child: Center(child: Text("No results found"))))
              : const SliverToBoxAdapter(),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
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
    } else if (buttonIndex == 2) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    } else {
      borderRadius = BorderRadius.zero;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = buttonIndex;
        });
      },
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        duration: const Duration(milliseconds: 300), // Duration of the animation
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedIndex == buttonIndex
              ? selectedContainerColor.withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)
              : unselectedContainerColor.withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
          border: buttonIndex == 1
              ? Border.symmetric(
                  horizontal: BorderSide(
                    width: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
                  ),
                )
              : Border.all(
                  width: 1.5,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
                ),
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .secondary
                .withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
