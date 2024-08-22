import 'package:flutter/material.dart';

import '../../../classes/Filters/region.dart';
import '../../../classes/Team/vdaStats.dart';
import '../../../classes/Team/world_skills.dart';

class WorldRankingsFilter {
  List<String>? regions;
  bool saved;
  bool onPickList;
  bool atTournament;
  bool scouted;

  WorldRankingsFilter({
    List<String>? regions,
    this.saved = false,
    this.onPickList = false,
    this.atTournament = false,
    this.scouted = false,
  }) : this.regions = regions ?? [];
}

Future<WorldRankingsFilter> worldRankingsFilter(
    BuildContext context,
    WorldRankingsFilter filter,
    bool isInTM,
    List<WorldSkillsStats> skills,
    List<VDAStats> vda) async {
  final DraggableScrollableController dra = DraggableScrollableController();

  bool inTM = isInTM;

  return await showModalBottomSheet<WorldRankingsFilter>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
                initialChildSize: inTM ? 0.6 : 0.45,
                maxChildSize: inTM ? 0.6 : 0.45,
                minChildSize: 0,
                expand: false,
                shouldCloseOnMinExtent: true,
                snapAnimationDuration: const Duration(milliseconds: 250),
                controller: dra,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 23, vertical: 24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: ListView(controller: scrollController, children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Filter",
                                style: TextStyle(
                                  fontSize: 24,
                                  height: 1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              filter.regions!.isNotEmpty ||
                                      filter.saved ||
                                      filter.onPickList ||
                                      filter.atTournament ||
                                      filter.scouted
                                  ? TextButton(
                                      child: Text("Clear",
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontWeight: FontWeight.w400,
                                          )),
                                      onPressed: () {
                                        setModalState(() {
                                          filter = WorldRankingsFilter();
                                        });
                                      },
                                    )
                                  : TextButton(
                                      child: const SizedBox(),
                                      onPressed: () {},
                                    ),
                            ]),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: filter.regions!.isNotEmpty
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          child: InkWell(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.language),
                                  const SizedBox(width: 10),
                                  filter.regions!.isEmpty
                                      ? const Text("All Regions",
                                          style: TextStyle(fontSize: 16))
                                      : Expanded(
                                          flex: 5,
                                          child: Text(
                                            filter.regions!.join(", "),
                                            style:
                                                const TextStyle(fontSize: 16),
                                            overflow: TextOverflow.fade,
                                            softWrap: false,
                                            maxLines: 1,
                                          )),
                                  const Spacer(),
                                  const Icon(Icons.arrow_right),
                                ]),
                            onTap: () async {
                              List<String> regions = skills
                                  .map((e) => e.eventRegion!.name)
                                  .toList();
                              regions.addAll(vda.map((e) => e.eventRegion!));
                              regions = regions.toSet().toList();
                              regions.sort();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoadedRegionFilterPage(
                                    filter: filter.regions!,
                                    regions: regions,
                                  ),
                                ),
                              );
                              setModalState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: filter.saved
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.bookmark_border),
                                      SizedBox(width: 10),
                                      Text("Saved",
                                          style: TextStyle(fontSize: 16)),
                                    ]),
                                filter.saved
                                    ? const Row(children: [
                                        Icon(Icons.check),
                                      ])
                                    : const SizedBox(),
                              ],
                            ),
                            onTap: () {
                              setModalState(() {
                                filter.saved = !filter.saved;
                              });
                            },
                          ),
                        ),
                        inTM ? const SizedBox(height: 12) : const SizedBox(),
                        inTM
                            ? Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                  color: filter.onPickList
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                ),
                                child: InkWell(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.person_add_alt),
                                            SizedBox(width: 10),
                                            Text("On Pick list",
                                                style: TextStyle(fontSize: 16)),
                                          ]),
                                      filter.onPickList
                                          ? const Row(children: [
                                              Icon(Icons.check),
                                            ])
                                          : const SizedBox(),
                                    ],
                                  ),
                                  onTap: () {
                                    setModalState(() {
                                      filter.onPickList = !filter.onPickList;
                                    });
                                  },
                                ),
                              )
                            : const SizedBox(),
                        inTM ? const SizedBox(height: 12) : const SizedBox(),
                        inTM
                            ? Container(
                                height: 50,
                                padding:
                                    const EdgeInsets.only(left: 20, right: 20),
                                decoration: BoxDecoration(
                                  color: filter.atTournament
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                ),
                                child: InkWell(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(Icons.people_alt_outlined),
                                            SizedBox(width: 10),
                                            Text("At This Tournament",
                                                style: TextStyle(fontSize: 16)),
                                          ]),
                                      filter.atTournament
                                          ? const Row(children: [
                                              Icon(Icons.check),
                                            ])
                                          : const SizedBox(),
                                    ],
                                  ),
                                  onTap: () {
                                    setModalState(() {
                                      filter.atTournament =
                                          !filter.atTournament;
                                    });
                                  },
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 12),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: filter.scouted
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          child: InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.manage_search),
                                      SizedBox(width: 10),
                                      Text("Scouted",
                                          style: TextStyle(fontSize: 16)),
                                    ]),
                                filter.scouted
                                    ? const Row(children: [
                                        Icon(Icons.check),
                                      ])
                                    : const SizedBox(),
                              ],
                            ),
                            onTap: () {
                              setModalState(() {
                                filter.scouted = !filter.scouted;
                              });
                            },
                          ),
                        )
                      ]));
                });
          },
        );
      }).then((_) {
    return filter;
  });
}
