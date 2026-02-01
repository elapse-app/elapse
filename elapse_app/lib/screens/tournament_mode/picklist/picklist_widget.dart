import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:collection/collection.dart';

import '../../../classes/Team/teamPreview.dart';
import '../../../classes/Tournament/division.dart';
import '../../../classes/Tournament/tournament.dart';
import '../../../main.dart';

class PicklistWidget extends StatefulWidget {
  const PicklistWidget({
    super.key,
    required this.index,
    required this.team,
    required this.carouselControllers,
    required this.refresh,
  });

  final int index;
  final TeamPreview team;
  final List<CarouselSliderController> carouselControllers;
  final Function refresh;

  @override
  State<PicklistWidget> createState() => _PicklistWidgetState();
}

class _PicklistWidgetState extends State<PicklistWidget> {
  Tournament? _tournament;
  Division? _division;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTournament();
  }

  Future<void> _loadTournament() async {
    final tournamentId = prefs.getInt("tournamentID");
    if (tournamentId != null && tournamentId != 0) {
      final tournament = await getTournamentFromCache(tournamentId);
      if (tournament != null && mounted) {
        _tournament = tournament;
        _division = tournament.divisions
            .firstWhereOrNull((e) => e.teamStats?.containsKey(widget.team.teamID) ?? false);
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTournamentStats(BuildContext context) {
    if (_isLoading || _tournament == null) {
      return const SizedBox.shrink();
    }

    final division = _division;

    if (division == null || division.teamStats == null) {
      return const SizedBox.shrink();
    }

    final stats = division.teamStats![widget.team.teamID]!;

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
                    Text("${stats.totalMatches > 0 ? (stats.wins / stats.totalMatches * 100).toStringAsFixed(1) : '0.0'}%",
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
          for (final c in widget.carouselControllers) {
            c.animateToPage(index,
                duration: const Duration(milliseconds: 100), curve: Curves.fastOutSlowIn);
          }
        },
      ),
      carouselController: widget.carouselControllers[widget.index],
    );
  }

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
            key: Key("${widget.index}"),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              final picklist = (prefs.getStringList("picklist") ?? []).map((e) => loadTeamPreview(e)).toList();
              picklist.remove(widget.team);
              prefs.setStringList("picklist", picklist.map((e) => jsonEncode(e.toJson())).toList());
              print(picklist);
              widget.refresh();
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
                    child: ReorderableDragStartListener(index: widget.index, child: const Icon(Icons.drag_indicator)),
                  ),
                  Flexible(
                    flex: 20,
                    fit: FlexFit.tight,
                    child: Text("${widget.index + 1}.",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontSize: 24, fontWeight: FontWeight.w600)),
                  ),
                  Flexible(
                    flex: 100,
                    fit: FlexFit.tight,
                    child: Text(widget.team.teamNumber,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface, fontSize: 36, fontWeight: FontWeight.w400)),
                  ),
                  Flexible(
                    flex: 90,
                    fit: FlexFit.tight,
                    child: _buildTournamentStats(context),
                  ),
                ])),
          ),
        ]));
  }
}
