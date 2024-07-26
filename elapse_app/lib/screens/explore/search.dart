import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/team_widget.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExploreSearch extends StatefulWidget {
  const ExploreSearch({super.key});

  @override
  State<ExploreSearch> createState() => _ExploreSearchState();
}

class _ExploreSearchState extends State<ExploreSearch> {
  final FocusNode _focusNode = FocusNode();
  String searchQuery = "";
  int selectedIndex = -1;
  Future<List<TeamPreview>>? teamSearch;
  Future<List<TournamentPreview>>? tournamentSearch;
  List<String> titles = ["Search for Something", "Teams", "Tournaments"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    setState(() {
      searchQuery = query;
      selectedIndex = 0;
      teamSearch = fetchTeamPreview(searchQuery);
      tournamentSearch = getTournaments(EventSearchFilters(
        seasonID: 190,
        eventName: searchQuery,
        startDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
        endDate: DateFormat("yyyy-MM-dd")
            .format(DateTime.now().add(Duration(days: 365))),
      ));
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
                                        },
                                      )),
                                  Flexible(
                                    flex: 6,
                                    child: TextField(
                                      focusNode: _focusNode,
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
                                                  onPressed: () {},
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
                minHeight: 50,
                maxHeight: 50,
                child: Hero(
                  tag: "top",
                  child: Stack(
                    children: [
                      Container(
                        color: Theme.of(context).colorScheme.primary,
                        height: 50,
                      ),
                      Container(
                        height: 50,
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
                          children: [
                            Text(
                              titles[selectedIndex + 1],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          selectedIndex == 0
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  sliver: SliverToBoxAdapter(
                    child: FutureBuilder<List<TeamPreview>>(
                      future: teamSearch,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        } else if (snapshot.hasData) {
                          if (snapshot.data?.isEmpty ?? true) {
                            return const Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Icon(
                                    Icons.search_off_outlined,
                                    size: 128,
                                    weight: 0.1,
                                  ),
                                  Text("No teams found"),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: snapshot.data!
                                .map((team) => Column(
                                      children: [
                                        TeamWidget(
                                          teamNumber: team.teamNumber,
                                          teamID: team.teamID,
                                          teamName: team.teamName,
                                          location: team.location,
                                        ),
                                        Divider(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceDim,
                                        )
                                      ],
                                    ))
                                .toList(),
                          );
                        } else {
                          return const Center(
                            child: Text("Search for teams or tournaments"),
                          );
                        }
                      },
                    ),
                  ),
                )
              : SliverToBoxAdapter(),
          selectedIndex == 1
              ? SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  sliver: SliverToBoxAdapter(
                    child: FutureBuilder(
                      future: tournamentSearch,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<TournamentPreview> tournaments =
                              snapshot.data as List<TournamentPreview>;
                          return Column(
                              children: tournaments
                                  .map((e) => TournamentPreviewWidget(
                                      tournamentPreview: e))
                                  .toList());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                )
              : SliverToBoxAdapter()
        ],
      ),
    );
  }

  Widget FilterButton(buttonIndex, maxHeight, text) {
    Color selectedContainerColor = Theme.of(context).colorScheme.primary;
    Color unselectedContainerColor = Theme.of(context).colorScheme.surface;
    Color disabledContainerColor =
        Theme.of(context).brightness == Brightness.light
            ? const Color.fromARGB(255, 221, 221, 221)
            : const Color.fromARGB(255, 21, 21, 21);
    Color disabledTextColor = Theme.of(context).brightness == Brightness.light
        ? const Color.fromARGB(255, 91, 91, 91)
        : const Color.fromARGB(255, 129, 129, 129);

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
        if (searchQuery != "") {
          setState(() {
            selectedIndex = buttonIndex;
          });
        }
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
            color: searchQuery != ""
                ? Theme.of(context).colorScheme.primary.withOpacity(
                    ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)
                : disabledContainerColor.withOpacity(
                    ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
          ),
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: searchQuery != ""
                ? Theme.of(context).colorScheme.secondary.withOpacity(
                    ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)
                : disabledTextColor.withOpacity(
                    ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
