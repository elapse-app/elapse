import 'package:flutter/material.dart';

import '../../../classes/Team/vdaStats.dart';
import '../../../classes/Team/world_skills.dart';
import '../../widgets/big_error_message.dart';

class WorldRankingsFilter {
  String? region;
  bool? saved;
  bool? onPicklist;
  bool? scouted;

  WorldRankingsFilter({
    String? region,
    bool? saved,
    bool? onPicklist,
    bool? scouted,
  });
}

Future<void> skillsFilterPage(BuildContext context,
    List<WorldSkillsStats>? skillsRankings, List<VDAStats>? vdaStats) {
  final DraggableScrollableController dra = DraggableScrollableController();

  List<String?> regions = [];
  if (vdaStats == null && skillsRankings != null) {
    regions = skillsRankings.map((e) => e.location?.region).toSet().toList();
  } else if (skillsRankings == null && vdaStats != null) {
    regions = vdaStats.map((e) => e.location?.region).toSet().toList();
  } else {
    return showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const BigErrorMessage(
            icon: Icons.filter_list,
            message: "No data to filter",
          );
        });
  }

  WorldRankingsFilter filters = WorldRankingsFilter();

  return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.8,
            minChildSize: 0,
            expand: false,
            shouldCloseOnMinExtent: true,
            snapAnimationDuration: const Duration(milliseconds: 250),
            controller: dra,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 23, vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: ListView(controller: scrollController, children: [
                    const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filter",
                            style: TextStyle(
                              fontSize: 24,
                              height: 1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownMenu(
                      initialSelection: regions.first,
                      onSelected: (String? val) {
                        filters.region = val;
                      },
                      dropdownMenuEntries:
                          regions.map<DropdownMenuEntry<String>>((String? val) {
                        return DropdownMenuEntry(value: val!, label: val);
                      }).toList(),
                    ),
                  ]));
            });
      });
}
