import 'package:elapse_app/classes/Filters/season.dart';
import 'package:elapse_app/classes/Filters/levelClass.dart';
import '../../classes/Filters/gradeLevel.dart';
import 'package:flutter/material.dart';

import '../../classes/Miscellaneous/location.dart';
import '../../main.dart';

class ExploreSearchFilter {
  Season season;
  LevelClass levelClass;
  GradeLevel gradeLevel;
  DateTime startDate;
  DateTime endDate;
  Location? location;

  ExploreSearchFilter({
    Season? season,
    LevelClass? levelClass,
    GradeLevel? gradeLevel,
    DateTime? startDate,
    DateTime? endDate,
    this.location,
  })  : this.season = season ?? seasons[0],
        this.levelClass = levelClass ?? levelClasses[0],
        this.gradeLevel = gradeLevel ?? getGradeLevel(prefs.getString("defaultGrade")),
        this.startDate =
            startDate ?? DateTime((season ?? seasons[0]).startYear.year, 5, 1),
        this.endDate =
            endDate ?? DateTime((season ?? seasons[0]).endYear.year, 4, 30);
}

Future<ExploreSearchFilter> exploreFilter(
    BuildContext context, ExploreSearchFilter filter) async {
  final DraggableScrollableController dra = DraggableScrollableController();

  List<GradeLevel> gradeFilters = gradeLevels.values.toList();
  gradeFilters.insert(0, GradeLevel(id: 0, name: "Middle and High School"));

  return await showModalBottomSheet<ExploreSearchFilter>(
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
                              filter.season != seasons[0] ||
                                      filter.levelClass != levelClasses[0] ||
                                      filter.startDate !=
                                          DateTime(filter.season.startYear.year,
                                              5, 1) ||
                                      filter.endDate !=
                                          DateTime(
                                              filter.season.endYear.year, 4, 30)
                                  ? TextButton(
                                      child: Text("Reset",
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
                                          filter = ExploreSearchFilter();
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
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          child: InkWell(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.event_note),
                                  const SizedBox(width: 10),
                                  Text(filter.season.name,
                                      style: const TextStyle(fontSize: 16)),
                                  const Spacer(),
                                  const Icon(Icons.arrow_right),
                                ]),
                            onTap: () async {
                              Season updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SeasonFilterPage(
                                    selected: filter.season,
                                  ),
                                ),
                              );
                              setModalState(() {
                                filter.season = updated;
                                filter.startDate = DateTime(
                                    filter.season.startYear.year, 5, 1);
                                filter.endDate =
                                    DateTime(filter.season.endYear.year, 4, 30);
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
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
                                  Text(filter.levelClass.name,
                                      style: const TextStyle(fontSize: 16)),
                                  const Spacer(),
                                  const Icon(Icons.arrow_right),
                                ]),
                            onTap: () async {
                              LevelClass updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LevelClassFilterPage(
                                    selected: filter.levelClass,
                                  ),
                                ),
                              );
                              setModalState(() {
                                filter.levelClass = updated;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.school),
                                const SizedBox(width: 10),
                                DropdownButton<GradeLevel>(
                                  value: filter.gradeLevel,
                                  items: gradeFilters.map((grade) {
                                    return DropdownMenuItem(
                                      value: grade,
                                      child: Text(grade.name,
                                          overflow: TextOverflow.fade,
                                          style: const TextStyle(fontSize: 16)),
                                    );
                                  }).toList(),
                                  onChanged: (GradeLevel? value) => {
                                    setModalState(() {
                                      filter.gradeLevel = value!;
                                    })
                                  },
                                ),
                              ],
                            )),
                        const SizedBox(height: 12),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          child: InkWell(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.calendar_month),
                                  const SizedBox(width: 10),
                                  Text(
                                      "Start Date: ${filter.startDate.month}/${filter.startDate.day}/${filter.startDate.year}",
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            onTap: () async {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: filter.startDate,
                                firstDate: DateTime(2010, 1, 1),
                                lastDate: DateTime(2030),
                              );
                              if (date != null && date != filter.startDate) {
                                setModalState(() {
                                  filter.startDate = date;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          child: InkWell(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.calendar_month),
                                  const SizedBox(width: 10),
                                  Text(
                                      "End Date: ${filter.endDate.month}/${filter.endDate.day}/${filter.endDate.year}",
                                      style: const TextStyle(fontSize: 16)),
                                ]),
                            onTap: () async {
                              final DateTime? date = await showDatePicker(
                                context: context,
                                initialDate: filter.endDate,
                                firstDate: DateTime(2010, 1, 1),
                                lastDate: DateTime(2030),
                              );
                              if (date != null && date != filter.endDate) {
                                setModalState(() {
                                  filter.endDate = date;
                                });
                              }
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
