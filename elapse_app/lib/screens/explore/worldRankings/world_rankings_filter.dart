import 'package:flutter/material.dart';

class WorldRankingsFilter {
  String region;
  bool saved;
  bool onPickList;
  bool scouted;

  WorldRankingsFilter({
    this.region = "All Regions",
    this.saved = false,
    this.onPickList = false,
    this.scouted = false,
  });
}

Future<WorldRankingsFilter> worldRankingsFilter(
    BuildContext context, WorldRankingsFilter filter) async {
  final DraggableScrollableController dra = DraggableScrollableController();

  List<String> regions = [
    "All Regions",
    "Ontario",
    "British Columbia",
    "Texas - Region 1",
    "Texas - Region 2"
  ];

  return await showModalBottomSheet<WorldRankingsFilter>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.5,
                maxChildSize: 0.5,
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
                              filter.region != "All Regions" ||
                                      filter.saved ||
                                      filter.onPickList ||
                                      filter.scouted
                                  ? TextButton(
                                      child: Text("clear",
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                            color: filter.region != "All Regions"
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
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.language),
                                      const SizedBox(width: 5),
                                      Text(filter.region,
                                          style: const TextStyle(fontSize: 16)),
                                    ]),
                                const Row(children: [
                                  Icon(Icons.arrow_right),
                                ])
                              ],
                            ),
                            onTap: () {
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
                                      SizedBox(width: 5),
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
                        const SizedBox(height: 12),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: filter.onPickList
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
                                      Icon(Icons.person_add_alt),
                                      SizedBox(width: 5),
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
                        ),
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
                                      SizedBox(width: 5),
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
                        ),
                      ]));
                });
          },
        );
      }).then((_) {
    return filter;
  });
}
