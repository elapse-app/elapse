import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';

import '../../../classes/Team/teamPreview.dart';
import '../../../classes/Tournament/tournament.dart';
import '../../../classes/Tournament/tstats.dart';
import '../../../main.dart';

class PicklistWidget extends StatelessWidget {
  const PicklistWidget({
    super.key,
    required this.index,
    required this.team,
    required this.tournament,
    required this.carouselControllers,
    required this.refresh,
  });

  final int index;
  final TeamPreview team;
  final Future<Tournament> tournament;
  final List<CarouselSliderController> carouselControllers;
  final Function refresh;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(clipBehavior: Clip.antiAlias, children: [
          Positioned.fill(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            child: Container(color: Theme.of(context).colorScheme.error),
          )),
          Dismissible(
            key: Key("$index"),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              final picklist = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
              picklist.remove(team);
              prefs.setStringList("picklist", picklist.map((e) => jsonEncode(e.toJson())).toList());
              print(picklist);
              refresh();
            },
            background: Container(
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              color: Theme.of(context).colorScheme.error,
              child: Icon(Icons.delete, color: Theme.of(context).colorScheme.surface),
            ),
            child: Container(
                height: 72,
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Flex(direction: Axis.horizontal, children: [
                  Flexible(
                    flex: 15,
                    fit: FlexFit.tight,
                    child: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_indicator)),
                  ),
                  Flexible(
                    flex: 20,
                    fit: FlexFit.tight,
                    child: Text("${index + 1}.",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  Flexible(
                    flex: 100,
                    fit: FlexFit.tight,
                    child: Text(team.teamNumber,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontSize: 36, fontWeight: FontWeight.w400)),
                  ),
                  Flexible(
                    flex: 90,
                    fit: FlexFit.tight,
                    child: FutureBuilder(
                        future: tournament,
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              return const Center(child: CircularProgressIndicator());
                            case ConnectionState.done:
                              if (snapshot.hasError) {
                                print(snapshot.error);
                                return const SizedBox.shrink();
                              }

                              TeamStats stats = (snapshot.data as Tournament)
                                  .divisions
                                  .firstWhereOrNull((e) => e.teamStats?.containsKey(team.teamID) ?? false)!
                                  .teamStats![team.teamID]!;

                              List<Widget> pages = [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(children: [
                                    Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Rank ${stats.rank}", style: const TextStyle(fontSize: 16)),
                                              Text("${stats.wp} WP", style: const TextStyle(fontSize: 16)),
                                            ])),
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: SizedBox(
                                        height: 50,
                                        child: VerticalDivider(
                                            thickness: 0.5, color: Theme.of(context).colorScheme.surfaceDim),
                                      ),
                                    ),
                                    Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text("${stats.ap} AP", style: const TextStyle(fontSize: 16)),
                                              Text("${stats.sp} SP", style: const TextStyle(fontSize: 16)),
                                            ])),
                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(children: [
                                    Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("${stats.wins}-${stats.losses}-${stats.ties}",
                                                  style: const TextStyle(fontSize: 16)),
                                              Text("${(stats.wins / stats.totalMatches * 100).toStringAsFixed(1)}%",
                                                  style: const TextStyle(fontSize: 16)),
                                            ])),
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: SizedBox(
                                        height: 50,
                                        child: VerticalDivider(
                                            thickness: 0.5, color: Theme.of(context).colorScheme.surfaceDim),
                                      ),
                                    ),
                                    Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text("${stats.awp} AWP", style: const TextStyle(fontSize: 16)),
                                              Text("${(stats.awpRate * 100).toStringAsFixed(1)}%",
                                                  style: const TextStyle(fontSize: 16)),
                                            ])),
                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(children: [
                                    Flexible(
                                        flex: 50,
                                        fit: FlexFit.tight,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("${stats.opr.toStringAsFixed(1)} OPR",
                                                  style: const TextStyle(fontSize: 16)),
                                              Text("${stats.dpr.toStringAsFixed(1)} DPR",
                                                  style: const TextStyle(fontSize: 16)),
                                            ])),
                                    Flexible(
                                      flex: 5,
                                      fit: FlexFit.tight,
                                      child: SizedBox(
                                        height: 50,
                                        child: VerticalDivider(
                                            thickness: 0.5, color: Theme.of(context).colorScheme.surfaceDim),
                                      ),
                                    ),
                                    Flexible(
                                        flex: 40,
                                        fit: FlexFit.tight,
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(stats.ccwm.toStringAsFixed(1), style: const TextStyle(fontSize: 16)),
                                              const Text("CCWM", style: TextStyle(fontSize: 16)),
                                            ])),
                                  ]),
                                ),
                              ];

                              return CarouselSlider(
                                items: pages,
                                options: CarouselOptions(
                                  viewportFraction: 1,
                                  enlargeFactor: 0,
                                  padEnds: true,
                                  onPageChanged: (index, reason) {
                                    for (final c in carouselControllers) {
                                      c.animateToPage(index,
                                          duration: const Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
                                    }
                                  },
                                ),
                                carouselController: carouselControllers[index],
                              );
                          }
                        }),
                  ),
                ])),
          ),
        ]));
  }
}
