import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/info/info.dart';
import 'package:elapse_app/screens/tournament/pages/main/search_screen.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/schedule.dart';
import 'package:elapse_app/screens/tournament/pages/skills/skills.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TournamentLoadedScreen extends StatefulWidget {
  final Tournament tournament;
  final bool isPreview;
  const TournamentLoadedScreen(
      {super.key, required this.tournament, this.isPreview = false});

  @override
  State<TournamentLoadedScreen> createState() => _TournamentLoadedScreenState();
}

class _TournamentLoadedScreenState extends State<TournamentLoadedScreen> {
  late int selectedIndex;
  int filterIndex = 0;
  List<String> titles = ["Schedule", "Rankings", "Skills", "Info"];
  List<String> filters = ["rank", "opr", "dpr", "ccwm", "ap", "sp"];

  final FocusNode _focusNode = FocusNode();

  late Division division;
  late bool inSearch;
  late String searchQuery;
  late String savedQuery;
  late double appBarHeight;

  List<Team> rankingsTeams = [];
  List<TeamPreview> savedTeams = [];
  bool useSavedTeams = false;
  bool useLiveTiming = true;

  void savedPress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      SchedulePage(
        division: division,
        tournament: widget.tournament,
        useLiveTiming: useLiveTiming,
      ),
      RankingsPage(
          searchQuery: searchQuery,
          rankings: division.teamStats!,
          teams: rankingsTeams,
          sort: filters[filterIndex],
          skills: widget.tournament.tournamentSkills!,
          games: division.games),
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
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 125,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    widget.isPreview
                        ? IconButton(
                            padding: const EdgeInsets.only(top: 10),
                            constraints: BoxConstraints(),
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )
                        : Container(),
                    Text(
                      titles[selectedIndex],
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 300),
                            reverseTransitionDuration:
                                Duration(milliseconds: 300),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SearchScreen(
                              tournament: widget.tournament,
                              division: division,
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                  ],
                ),
              ),
              centerTitle: false,
              background: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 12, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<Division>(
                            value: division,
                            borderRadius: BorderRadius.circular(20),
                            items: widget.tournament.divisions
                                .map<DropdownMenuItem<Division>>((division) {
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
                          const Spacer(),
                          const SettingsButton()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                            _buildIconButton(context,
                                Icons.format_list_numbered_outlined, 1),
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
          ),
          selectedIndex == 0 && division.teamStats?.isNotEmpty == true
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 23),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Enable Live Timing",
                          style: TextStyle(fontSize: 16),
                        ),
                        Switch(
                          value: useLiveTiming,
                          onChanged: (bool value) {
                            setState(() {
                              useLiveTiming = value;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                )
              : SliverToBoxAdapter(),
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
          pages[selectedIndex],
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
