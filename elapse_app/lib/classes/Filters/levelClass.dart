import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/widgets/app_bar.dart';
import '../../screens/widgets/custom_tab_bar.dart';

class LevelClass {
  int id;
  String name;

  LevelClass({
    required this.id,
    required this.name,
  });
}

List<LevelClass> levelClasses = [
  LevelClass(id: 0, name: "All Levels"),
  LevelClass(id: 1, name: "Event Region Championship"),
  LevelClass(id: 2, name: "National Championship"),
  LevelClass(id: 3, name: "World Championship"),
  LevelClass(id: 9, name: "Signature Event"),
  LevelClass(id: 12, name: "JROTC Brigade Championship"),
  LevelClass(id: 13, name: "JROTC National Championship"),
  LevelClass(id: 16, name: "Showcase Event")
];

class LevelClassFilterPage extends StatefulWidget {
  LevelClassFilterPage({
    super.key,
    required this.selected,
  });

  LevelClass selected;

  @override
  State<LevelClassFilterPage> createState() => _LevelClassFilterPageState();
}

class _LevelClassFilterPageState extends State<LevelClassFilterPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    List<LevelClass> filteredSeason = levelClasses;
    if (searchQuery.isNotEmpty) {
      filteredSeason = levelClasses
          .where((e) => e.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(slivers: [
        ElapseAppBar(
          title: const Row(children: [
            Text(
              "Filter by Level Class",
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
                                style: const TextStyle(fontSize: 16),
                              ),
                              selected
                                  ? const Icon(Icons.check)
                                  : const SizedBox(),
                            ]),
                      ),
                      onTap: () {
                        setState(() {
                          widget.selected = season;
                        });
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