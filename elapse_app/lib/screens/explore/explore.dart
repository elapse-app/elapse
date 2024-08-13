import 'package:elapse_app/screens/explore/search.dart';
import 'package:elapse_app/screens/explore/worldRankings.dart';
import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
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
              title: const Padding(
                padding: EdgeInsets.only(left: 20, right: 12),
                child: Text(
                  "Explore",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ),
              centerTitle: false,
              background: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 12, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          SettingsButton(
                            prefs: prefs,
                          ),
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
                minHeight: 25,
                maxHeight: 25,
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
                )),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 300),
                          reverseTransitionDuration:
                              const Duration(milliseconds: 300),
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  ExploreSearch(prefs: prefs),
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
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 24,
                          ),
                          SizedBox(width: 13),
                          Text(
                            "Search teams or tournaments",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // const SliverToBoxAdapter(
          //   child: SizedBox(height: 12),
          // ),
          // SliverToBoxAdapter(
          //   child: recentSearches.isNotEmpty
          //       ? SizedBox(
          //           height: 40,
          //           child: ListView.builder(
          //             scrollDirection: Axis.horizontal,
          //             itemBuilder: (context, index) {
          //               if (index == 0) {
          //                 return const SizedBox(
          //                   width: 23,
          //                 );
          //               } else if (index == recentSearches.length + 1) {
          //                 return const SizedBox(
          //                   width: 23,
          //                 );
          //               }
          //               return GestureDetector(
          //                 onTap: () {
          //                   if (recentSearches[index - 1].teamID != null) {
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                         builder: (context) => TeamScreen(
          //                           teamID: recentSearches[index - 1].teamID!,
          //                           teamName:
          //                               recentSearches[index - 1].searchTerm,
          //                         ),
          //                       ),
          //                     );
          //                   } else if (recentSearches[index - 1].tournamentID !=
          //                       null) {
          //                     Navigator.push(
          //                       context,
          //                       MaterialPageRoute(
          //                         builder: (context) => TournamentScreen(
          //                           tournamentID:
          //                               recentSearches[index - 1].tournamentID!,
          //                         ),
          //                       ),
          //                     );
          //                   }
          //                 },
          //                 child: Container(
          //                   height: 40,
          //                   alignment: Alignment.center,
          //                   margin: const EdgeInsets.only(right: 8),
          //                   padding: const EdgeInsets.symmetric(horizontal: 18),
          //                   decoration: BoxDecoration(
          //                     border: Border.all(
          //                       color: Theme.of(context).colorScheme.primary,
          //                     ),
          //                     borderRadius: BorderRadius.circular(20),
          //                   ),
          //                   child: Row(
          //                     children: [
          //                       if (recentSearches[index - 1].teamID != null)
          //                         const Icon(
          //                           Icons.groups_3_outlined,
          //                           size: 16,
          //                         ),
          //                       if (recentSearches[index - 1].tournamentID !=
          //                           null)
          //                         const Icon(
          //                           Icons.emoji_events_outlined,
          //                           size: 16,
          //                         ),
          //                       SizedBox(
          //                         width: 12,
          //                       ),
          //                       Text(recentSearches[index - 1].searchTerm,
          //                           style: const TextStyle(
          //                               fontSize: 16, height: 1)),
          //                     ],
          //                   ),
          //                 ),
          //               );
          //             },
          //             itemCount: recentSearches.length + 2,
          //           ))
          //       : Container(),
          // ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 23),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              height: 64,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(18)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 65,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WorldRankingsScreen(initState: 0)));
                        },
                        child: const Text(
                          "World Skills",
                          style: TextStyle(fontSize: 16, height: 1),
                          textAlign: TextAlign.center,
                        ),
                      )),
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 10,
                      child: VerticalDivider(
                        width: 1,
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      )),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 65,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WorldRankingsScreen(initState: 1)));
                      },
                      child: const Text(
                        "World TrueSkill",
                        style: TextStyle(fontSize: 16, height: 1),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 35,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Robotics Updates",
                    style: TextStyle(fontSize: 24),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 18),
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Update Title",
                                style: TextStyle(fontSize: 20)),
                            Icon(
                              Icons.arrow_forward,
                              size: 24,
                            )
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Change 1",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Game manual change 1",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Change 1",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Game manual change 1",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Change 1",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "Game manual change 1",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
