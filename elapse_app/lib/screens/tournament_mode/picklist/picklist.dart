import 'dart:convert';
import 'dart:ui';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament_mode/picklist/picklist_widget.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../classes/Team/teamPreview.dart';
import '../../../classes/Tournament/tournament.dart';
import '../../../main.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/rounded_top.dart';

class PicklistPage extends StatefulWidget {
  const PicklistPage({super.key});

  @override
  State<PicklistPage> createState() => _PicklistPageState();
}

class _PicklistPageState extends State<PicklistPage> {
  List<TeamPreview> teams = [];
  late Future<Tournament> tournament;

  List<CarouselSliderController> carouselControllers = [];

  void refreshTeams() {
    setState(() {
      teams = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
      carouselControllers = [];
      for (var _ in teams) {
        carouselControllers.add(CarouselSliderController());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    refreshTeams();
    tournament = TMTournamentDetails(prefs.getInt("tournamentID") ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: CustomScrollView(slivers: [
          const ElapseAppBar(
            title: Text(
              "My Picklist",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            backNavigation: true,
          ),
          const RoundedTop(),
          prefs.getBool("isTournamentMode") ?? false
              ? SliverToBoxAdapter(
                  child: ReorderableListView(
                      padding: const EdgeInsets.symmetric(horizontal: 23),
                      shrinkWrap: true,
                      children: teams
                          .asMap()
                          .map<int, Widget>((i, e) {
                            return MapEntry(
                                i,
                                Column(key: UniqueKey(), mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  PicklistWidget(
                                      index: i,
                                      team: e,
                                      tournament: tournament,
                                      carouselControllers: carouselControllers,
                                      refresh: refreshTeams),
                                  i != teams.length - 1
                                      ? Divider(
                                          color: Theme.of(context).colorScheme.surfaceDim,
                                          height: 3,
                                        )
                                      : const SizedBox.shrink(),
                                ]));
                          })
                          .values
                          .toList(),
                      onReorder: (int prev, int curr) {
                        setState(() {
                          if (prev < curr) curr--;
                          final team = teams.removeAt(prev);
                          teams.insert(curr, team);
                        });
                      },
                      onReorderEnd: (int index) {
                        prefs.setStringList("picklist", teams.map((e) => jsonEncode(e.toJson())).toList());
                      },
                      proxyDecorator: (child, index, animation) => AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) => Material(
                              elevation: lerpDouble(0, 6, Curves.easeInOut.transform(animation.value))!,
                              borderRadius: const BorderRadius.all(Radius.circular(18)),
                              shadowColor: Theme.of(context).colorScheme.tertiary,
                              child: child,
                            ),
                            child: child,
                          )),
                )
              : const SliverToBoxAdapter(
                  child: BigErrorMessage(
                      icon: Icons.list_alt_outlined, message: "Picklist is only available during tournament mode")),
        ]));
  }
}
