import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournament_mode_functions.dart';
import 'package:elapse_app/screens/tournament/pages/main/search_screen.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:elapse_app/screens/tournament_mode/widgets/next_game.dart';
import 'package:elapse_app/screens/tournament_mode/widgets/ranking_overview_widget.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';

class TMHomePage extends StatefulWidget {
  const TMHomePage(
      {super.key,
      required this.tournament,
      required this.teamID,
      required this.teamNumber});
  final Future<Tournament>? tournament;
  final int teamID;
  final String teamNumber;

  @override
  State<TMHomePage> createState() => _TMHomePageState();
}

class _TMHomePageState extends State<TMHomePage> {
  @override
  Widget build(BuildContext context) {
    String imageString =
        Theme.of(context).colorScheme.brightness == Brightness.dark
            ? "assets/dg4x.png"
            : "assets/lg4x.png";
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 190,
            centerTitle: false,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                double sizedBoxHeight = (top - kToolbarHeight) * 0.65 -
                    MediaQuery.of(context).viewPadding.top;
                sizedBoxHeight = sizedBoxHeight < 0 ? 0 : sizedBoxHeight;
                return FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.parallax,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Spacer(),
                        const Text(
                          "Good Afternoon",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w600),
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
                      padding: const EdgeInsets.only(
                          left: 20, right: 12, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Image(image: AssetImage(imageString), height: 25),
                              const Spacer(),
                              const SettingsButton()
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FutureBuilder(
                              future: widget.tournament,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          transitionDuration:
                                              const Duration(milliseconds: 300),
                                          reverseTransitionDuration:
                                              const Duration(milliseconds: 300),
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              SearchScreen(
                                                  tournament: snapshot.data!,
                                                  division: snapshot
                                                      .data!.divisions[0]),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            // Create a Tween that transitions the new screen from fully transparent to fully opaque
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 60,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18.0),
                                            child: Icon(Icons.search,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary),
                                          ),
                                          Text("Search your tournament",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSecondary)),
                                        ],
                                      ),
                                    ),
                                  );
                                } else {
                                  return Container(
                                    height: 60,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 18.0),
                                          child: Icon(Icons.search,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary),
                                        ),
                                        Text("Search your tournament",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSecondary)),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
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
          FutureBuilder(
            future: widget.tournament,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.divisions[0].games!.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 23),
                      child: Container(
                          padding: EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(18)),
                          child: Text(
                            "No games currently available",
                            style: TextStyle(fontSize: 16),
                          )),
                    ),
                  );
                }
                List<Game> upcomingGames = getTeamGames(
                        snapshot.data!.divisions[0].games!, widget.teamNumber)
                    .where(
                  (element) {
                    return element.startedTime == null &&
                        element.redScore == null;
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
                            "No games currently available",
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
                          games: snapshot.data!.divisions[0].games!,
                          rankings: snapshot.data!.divisions[0].teamStats!,
                          skills: snapshot.data!.tournamentSkills!,
                          targetTeam: TeamPreview(
                              teamNumber: widget.teamNumber,
                              teamID: widget.teamID),
                        ),
                        // SizedBox(height: 25),
                        // RankingOverviewWidget(
                        //   teamStats: snapshot
                        //       .data!.divisions[0].teamStats![widget.teamID]!,
                        //   skills: snapshot.data!.tournamentSkills!,
                        //   teamID: widget.teamID,
                        // ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(child: CircularProgressIndicator())),
                );
              }
            },
          ),
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
          FutureBuilder(
            future: widget.tournament,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Game> upcomingGames = getTeamGames(
                        snapshot.data!.divisions[0].games!, widget.teamNumber)
                    .where(
                  (element) {
                    return element.startedTime == null &&
                        element.redScore == null;
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
                            "No upcoming Games",
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
                                rankings: snapshot.data!.divisions[0].teamStats,
                                games: snapshot.data!.divisions[0].games!,
                                skills: snapshot.data!.tournamentSkills),
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
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(child: CircularProgressIndicator())),
                );
              }
            },
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          FutureBuilder(
            future: widget.tournament,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  sliver: SliverToBoxAdapter(
                    child: snapshot.data!.divisions[0].teamStats!.isNotEmpty &&
                            snapshot.data!.tournamentSkills!.isNotEmpty
                        ? RankingOverviewWidget(
                            teamStats: snapshot
                                .data!.divisions[0].teamStats![widget.teamID]!,
                            skills: snapshot.data!.tournamentSkills!,
                            teamID: widget.teamID,
                          )
                        : Container(),
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(child: CircularProgressIndicator())),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
