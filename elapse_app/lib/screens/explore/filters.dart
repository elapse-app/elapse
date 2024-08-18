import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
import 'package:elapse_app/classes/Filters/season.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage({super.key, required this.filters});
  final EventSearchFilters filters;

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  List<Season> seasons = [
    Season(id: 190, name: "24-25 High Stakes", programID: 1),
    Season(id: 181, name: "23-24 Over Under", programID: 1),
    Season(id: 173, name: "22-23 Spin Up", programID: 1),
    Season(id: 154, name: "21-22 Tipping Point", programID: 1),
    Season(id: 139, name: "20-21 Change Up", programID: 1),
    Season(id: 130, name: "19-20 Tower Takeover", programID: 1),
    Season(id: 125, name: "18-19 Turning Point", programID: 1),
    Season(id: 119, name: "17-18 In The Zone", programID: 1),
    Season(id: 115, name: "16-17 Starstruck", programID: 1),
    Season(id: 110, name: "15-16 Nothing but Net", programID: 1),
    Season(id: 102, name: "14-15 Skyrise", programID: 1),
    Season(id: 92, name: "13-14 Toss Up", programID: 1),
    Season(id: 85, name: "12-13 Sack Attack", programID: 1),
    Season(id: 73, name: "11-12 Gateway", programID: 1),
    Season(id: 7, name: "10-11 Round Up", programID: 1),
    Season(id: 1, name: "9-10 Clean Sweep", programID: 1),
  ];
  late int levelClassID;

  late Season season;
  late EventSearchFilters returnFilters;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    levelClassID = 1;
    season = seasons[0];
    returnFilters = widget.filters;
    startDate = DateTime.parse(widget.filters.startDate);
    endDate = DateTime.parse(widget.filters.endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Filters",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 16,
              ),
              Text(
                "Season",
                style: TextStyle(fontSize: 24),
              ),
              DropdownButton<Season>(
                value: season,
                items: seasons.map((season) {
                  return DropdownMenuItem(
                    child: Text(
                      season.name,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: season,
                  );
                }).toList(),
                onChanged: (Season? value) => {
                  setState(() {
                    season = value!;
                    returnFilters.seasonID = value.id;
                  })
                },
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Dates",
                style: TextStyle(fontSize: 24),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.only(right: 10, top: 10, bottom: 10),
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2010, 1, 1),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != startDate) {
                          setState(() {
                            startDate = picked;
                            returnFilters.startDate =
                                DateFormat("yyyy-MM-dd").format(picked);
                          });
                        }
                      },
                      child: Text(
                        "Start Date: ${startDate.month}/${startDate.day}/${startDate.year}",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.only(top: 10, bottom: 10, right: 10),
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: endDate,
                          firstDate: DateTime(2010, 1, 1),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != endDate) {
                          setState(() {
                            endDate = picked;
                            returnFilters.endDate =
                                DateFormat("yyyy-MM-dd").format(picked);
                          });
                        }
                      },
                      child: Text(
                        "End Date: ${endDate.month}/${endDate.day}/${endDate.year}",
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Level Class",
                style: TextStyle(fontSize: 24),
              ),
              DropdownButton(
                value: levelClassID,
                items: const [
                  DropdownMenuItem(
                      value: 1, child: Text("Event Region Championship")),
                  DropdownMenuItem(
                      value: 2, child: Text("National Championship")),
                  DropdownMenuItem(value: 3, child: Text("World Championship")),
                  DropdownMenuItem(value: 9, child: Text("Signature Event")),
                  DropdownMenuItem(
                      value: 12, child: Text("JROTC Brigade Championship")),
                  DropdownMenuItem(
                      value: 13, child: Text("JROTC National Championship")),
                  DropdownMenuItem(value: 16, child: Text("Showcase Event")),
                ],
                onChanged: (int? value) => {
                  setState(() {
                    levelClassID = value!;
                    returnFilters.levelClassID = value.toString();
                  })
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 20, right: 20, bottom: 20),
                ),
                child: Text(
                  "Save Filters",
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  Navigator.pop(context, returnFilters);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
