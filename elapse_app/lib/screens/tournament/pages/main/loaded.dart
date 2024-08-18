import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/info/info.dart';
import 'package:elapse_app/screens/tournament/pages/main/search_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/qualification_matches.dart';
import 'package:elapse_app/screens/tournament/pages/skills/skills.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/main.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class TournamentLoadedScreen extends StatefulWidget {
  final Tournament tournament;
  final bool isPreview;
  const TournamentLoadedScreen({
    super.key,
    required this.tournament,
    this.isPreview = false,
  });

  @override
  State<TournamentLoadedScreen> createState() => _TournamentLoadedScreenState();
}

class _TournamentLoadedScreenState extends State<TournamentLoadedScreen>
    with TickerProviderStateMixin {
  late int selectedIndex;
  int filterIndex = 0;
  List<String> titles = ["Schedule", "Rankings", "Skills", "Info"];
  List<String> filters = ["rank", "opr", "dpr", "ccwm", "ap", "sp"];

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
  bool useLiveTiming = true;

  List<Game> practice = [];
  List<Game> qualifications = [];
  List<Game> eliminations = [];

  List<Widget> widgets = [SliverToBoxAdapter(), SliverToBoxAdapter()];

  void savedPress() {
    setState(() {
      useSavedTeams = !useSavedTeams;
      if (useSavedTeams) {
        final String savedTeam = prefs.getString("savedTeam") ?? "";
        TeamPreview savedTeamPreview = TeamPreview(
            teamID: jsonDecode(savedTeam)["teamID"],
            teamNumber: jsonDecode(savedTeam)["teamNumber"]);
        List<String> savedTeamsString = prefs.getStringList("savedTeams") ?? [];
        savedTeams.add(savedTeamPreview);
        savedTeams.addAll(savedTeamsString
            .map((e) => TeamPreview(
                teamID: jsonDecode(e)["teamID"],
                teamNumber: jsonDecode(e)["teamNumber"]))
            .toList());
        rankingsTeams = widget.tournament.teams
            .where((element) =>
                savedTeams.any((element2) => element2.teamID == element.id))
            .toList();
      } else {
        rankingsTeams = widget.tournament.teams;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    rankingsTeams = widget.tournament.teams;
    division = widget.tournament.divisions[0];
    inSearch = false;
    searchQuery = "";
    savedQuery = "";
    _scrollController = ScrollController();

    if (widget.tournament.divisions[0].games == null ||
        widget.tournament.divisions[0].games!.isEmpty) {
      selectedIndex = 3;
    } else {
      selectedIndex = 0;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (division.games != null && division.games!.isNotEmpty) {
      practice = division.games!.where((game) => game.roundNum == 1).toList();
      qualifications =
          division.games!.where((game) => game.roundNum == 2).toList();
      eliminations =
          division.games!.where((game) => game.roundNum > 2).toList();
    }

    List<Widget> pages = [
      SliverToBoxAdapter(),
      RankingsPage(
        searchQuery: searchQuery,
        sort: filters[filterIndex],
        divisionIndex: division.order - 1,
        useSavedTeams: useSavedTeams,
      ),
      SkillsPage(
          skills: widget.tournament.tournamentSkills!,
          teams: widget.tournament.teams,
          divisions: widget.tournament.divisions),
      InfoPage(
        // InfoPage is a StatelessWidget
        tournament: widget.tournament,
        awards: widget.tournament.awards,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          ElapseAppBar(
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
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SearchScreen(
                          tournament: widget.tournament,
                          division: division,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
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
                padding: const EdgeInsets.only(left: 23, right: 12, bottom: 20),
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
                                child: Icon(Icons.arrow_back,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              Spacer(),
                              DropdownButton<Division>(
                                value: division,
                                borderRadius: BorderRadius.circular(20),
                                items: widget.tournament.divisions
                                    .map<DropdownMenuItem<Division>>(
                                        (division) {
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
                                onChanged: (Division? value) => {
                                  setState(() {
                                    division = value!;
                                    selectedIndex = selectedIndex;
                                  })
                                },
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<Division>(
                                value: division,
                                borderRadius: BorderRadius.circular(20),
                                items: widget.tournament.divisions
                                    .map<DropdownMenuItem<Division>>(
                                        (division) {
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
                                onChanged: (Division? value) => {
                                  setState(() {
                                    division = value!;
                                    selectedIndex = selectedIndex;
                                  })
                                },
                              ),
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
                  Container(
                      height: 300,
                      color: Theme.of(context).colorScheme.primary),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildIconButton(context, Icons.schedule, 0),
                          _buildIconButton(
                              context, Icons.format_list_numbered_outlined, 1),
                          _buildIconButton(
                              context, Icons.sports_esports_outlined, 2),
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
                          flex: 1,
                          child: IconButton(
                            icon: Icon(
                              useSavedTeams
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              size: 30,
                            ),
                            onPressed: savedPress,
                          ),
                        ),
                        Flexible(
                          flex: 4,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: 13,
                              ),
                              _buildFilterButton(context, "Rank", 0),
                              _buildFilterButton(context, "OPR", 1),
                              _buildFilterButton(context, "DPR", 2),
                              _buildFilterButton(context, "CCWM", 3),
                              _buildFilterButton(context, "AP", 4),
                              _buildFilterButton(context, "SP", 5),
                            ],
                          ),
                        ),
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
                  header: ScheduleTab(
                      Theme.of(context).colorScheme.surface, "Practice", () {
                    setState(() {
                      showPractice = !showPractice;
                    });
                  }, showPractice),
                  sliver: showPractice
                      ? MatchesView(games: practice, useLiveTiming: true)
                      : SliverToBoxAdapter(),
                )
              : SliverToBoxAdapter(),

          selectedIndex == 0 && qualifications.isNotEmpty
              ? SliverStickyHeader(
                  header: ScheduleTab(
                      Theme.of(context).colorScheme.surface, "Qualifications",
                      () {
                    setState(() {
                      showQualification = !showQualification;
                    });
                  }, showQualification),
                  sliver: showQualification
                      ? MatchesView(games: qualifications, useLiveTiming: true)
                      : SliverToBoxAdapter(),
                )
              : SliverToBoxAdapter(),

          selectedIndex == 0 && eliminations.isNotEmpty
              ? SliverStickyHeader(
                  header: ScheduleTab(
                      Theme.of(context).colorScheme.surface, "Eliminations",
                      () {
                    setState(() {
                      showElimination = !showElimination;
                    });
                  }, showElimination),
                  sliver: showElimination
                      ? MatchesView(games: eliminations, useLiveTiming: true)
                      : SliverToBoxAdapter(),
                )
              : SliverToBoxAdapter(),

          pages[selectedIndex],
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
            ),
          )
        ],
      ),
    );
  }

  Widget ScheduleTab(Color backgroundColor, String title, void Function() onTap,
      bool variable) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 23, vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 24),
          ),
          IconButton(
            focusColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onPressed: onTap,
            icon: Icon(variable
                ? Icons.keyboard_arrow_down
                : Icons.keyboard_arrow_right),
          ),
        ],
      ),
    );
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
            color: selectedIndex == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
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

  TextButton _buildFilterButton(BuildContext context, String name, int index) {
    Color backgroundColor = index == filterIndex
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surface;
    return TextButton(
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4)),
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.primary)),
          child: Text(name,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onSurface))),
      onPressed: () {
        setState(() {
          filterIndex = index;
        });
      },
    );
  }
}
