import 'package:flutter/material.dart';

class TournamentRankingsFilter {
  bool saved;
  bool onPicklist;
  bool scouted;

  TournamentRankingsFilter({
    this.saved = false,
    this.onPicklist = false,
    this.scouted = false,
  });
}

Future<TournamentRankingsFilter> worldRankingsFilter(
    BuildContext context,
    TournamentRankingsFilter filter,
    bool inTM) async {
  final DraggableScrollableController dra = DraggableScrollableController();

  return await showModalBottomSheet<TournamentRankingsFilter>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.45,
                maxChildSize: 0.45,
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
                                  filter.saved ||
                                  filter.onPicklist ||
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
                                    filter = TournamentRankingsFilter();
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
                            color: filter.onPicklist
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
                                      Text("On Picklist",
                                          style: TextStyle(fontSize: 16)),
                                    ]),
                                filter.onPicklist
                                    ? const Row(children: [
                                  Icon(Icons.check),
                                ])
                                    : const SizedBox(),
                              ],
                            ),
                            onTap: () {
                              setModalState(() {
                                filter.onPicklist = !filter.onPicklist;
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
