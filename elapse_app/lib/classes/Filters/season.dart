import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/widgets/app_bar.dart';
import '../../screens/widgets/custom_tab_bar.dart';

class Season {
  int vrcId;
  int? vexUId;
  String name;
  int programID;

  DateTime startYear;
  DateTime endYear;

  Season({
    required this.vrcId,
    this.vexUId,
    required this.name,
    required this.programID,
    required this.startYear,
    required this.endYear,
  });
}

List<Season> seasons = [
  Season(vrcId: 190, vexUId: 191, name: "2024-2025 High Stakes", programID: 1, startYear: DateTime(2024), endYear: DateTime(2025)),
  Season(vrcId: 181, vexUId: 182, name: "2023-2024 Over Under", programID: 1, startYear: DateTime(2023), endYear: DateTime(2024)),
  Season(vrcId: 173, vexUId: 175, name: "2022-2023 Spin Up", programID: 1, startYear: DateTime(2022), endYear: DateTime(2023)),
  Season(vrcId: 154, vexUId: 156, name: "2021-2022 Tipping Point", programID: 1, startYear: DateTime(2021), endYear: DateTime(2022)),
  Season(vrcId: 139, vexUId: 140, name: "2020-2021 Change Up", programID: 1, startYear: DateTime(2020), endYear: DateTime(2021)),
  Season(vrcId: 130, vexUId: 131, name: "2019-2020 Tower Takeover", programID: 1, startYear: DateTime(2019), endYear: DateTime(2020)),
  Season(vrcId: 125, vexUId: 126, name: "2018-2019 Turning Point", programID: 1, startYear: DateTime(2018), endYear: DateTime(2019)),
  Season(vrcId: 119, vexUId: 120, name: "2017-2018 In The Zone", programID: 1, startYear: DateTime(2017), endYear: DateTime(2018)),
  Season(vrcId: 115, vexUId: 116, name: "2016-2017 Starstruck", programID: 1, startYear: DateTime(2016), endYear: DateTime(2017)),
  Season(vrcId: 110, vexUId: 111, name: "2015-2016 Nothing but Net", programID: 1, startYear: DateTime(2015), endYear: DateTime(2016)),
  Season(vrcId: 102, vexUId: 103, name: "2014-2015 Skyrise", programID: 1, startYear: DateTime(2014), endYear: DateTime(2015)),
  Season(vrcId: 92, vexUId: 93, name: "2013-2014 Toss Up", programID: 1, startYear: DateTime(2013), endYear: DateTime(2014)),
  Season(vrcId: 85, vexUId: 88, name: "2012-2013 Sack Attack", programID: 1, startYear: DateTime(2012), endYear: DateTime(2013)),
  Season(vrcId: 73, vexUId: 76, name: "2011-2012 Gateway", programID: 1, startYear: DateTime(2011), endYear: DateTime(2012)),
  Season(vrcId: 7, vexUId: 10, name: "2010-2011 Round Up", programID: 1, startYear: DateTime(2010), endYear: DateTime(2011)),
  Season(vrcId: 1, vexUId: 4, name: "2009-2010 Clean Sweep", programID: 1, startYear: DateTime(2009), endYear: DateTime(2010)),
];

class SeasonFilterPage extends StatefulWidget {
  SeasonFilterPage({
    super.key,
    required this.selected,
    List<Season>? seasonsList,
  }) : this.seasonsList = seasonsList ?? seasons;

  Season selected;
  List<Season> seasonsList;

  @override
  State<SeasonFilterPage> createState() => _SeasonFilterPageState();
}

class _SeasonFilterPageState extends State<SeasonFilterPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<Season> filteredSeason = seasons;
    if (searchQuery.isNotEmpty) {
      filteredSeason = seasons
          .where((e) => e.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(slivers: [
        ElapseAppBar(
          title: const Row(children: [
            Text(
              "Filter by Season",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ]),
          backNavigation: true,
          returnData: widget.selected,
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverHeaderDelegate(
            maxHeight: 60,
            minHeight: 60,
            child: Hero(
              tag: "top",
              child: Stack(
                children: [
                  Container(
                    color: Theme.of(context).colorScheme.primary,
                    height: 60,
                  ),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.search),
                          hintText: "Filter seasons",
                          border: InputBorder.none,
                        ),
                      ))
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final season = filteredSeason[index];
              bool selected = widget.selected == season;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(children: [
                  GestureDetector(
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                          const BorderRadius.all(Radius.circular(10)),
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        margin: const EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                season.name,
                                style: TextStyle(
                                    fontSize: 16,
                                  color: widget.seasonsList.contains(season) ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.surfaceDim,
                                ),
                              ),
                              selected
                                  ? const Icon(Icons.check)
                                  : const SizedBox(),
                            ]),
                      ),
                      onTap: () {
                        setState(() {
                          if (widget.seasonsList.contains(season)) {
                            widget.selected = season;
                          }
                        });
                        Navigator.pop(context, widget.selected);
                      }),
                  index != filteredSeason.length - 1
                      ? Divider(
                    height: 3,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  )
                      : Container(),
                ]),
              );
            },
            childCount: filteredSeason.length,
          ),
        ),
      ]),
    );
  }
}