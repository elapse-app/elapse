import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/widgets/app_bar.dart';
import '../../screens/widgets/custom_tab_bar.dart';
import '../Team/vdaStats.dart';
import '../Team/world_skills.dart';

class Region {
  String name;
  int id;

  Region({
    required this.name,
    required this.id,
  });
}

class RegionFilterPage extends StatefulWidget {
  RegionFilterPage({
    super.key,
    required this.filter,
    required this.skills,
    required this.vda,
  });

  List<String> filter;
  Future<List<WorldSkillsStats>> skills;
  Future<List<VDAStats>> vda;

  @override
  State<RegionFilterPage> createState() => _RegionFilterPageState();
}

class _RegionFilterPageState extends State<RegionFilterPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([widget.skills, widget.vda]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          } else if (snapshot.hasData) {
            List<String> regions = (snapshot.data?[0] as List<WorldSkillsStats>)
                .map((e) => e.eventRegion!.name)
                .toList();
            regions.addAll((snapshot.data?[1] as List<VDAStats>)
                .map((e) => e.eventRegion!));
            regions = regions.toSet().toList();
            regions.sort();
            return LoadedRegionFilterPage(
                regions: regions, filter: widget.filter);
          } else {
            return const BigErrorMessage(
                icon: Icons.filter_list_outlined,
                message: "Unable to load regions");
          }
        });
  }
}

class LoadedRegionFilterPage extends StatefulWidget {
  LoadedRegionFilterPage({
    super.key,
    required this.regions,
    required this.filter,
  });

  final List<String> regions;
  List<String> filter;

  @override
  State<LoadedRegionFilterPage> createState() => _LoadedRegionFilterPageState();
}

class _LoadedRegionFilterPageState extends State<LoadedRegionFilterPage> {
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> regions = widget.regions;
    if (searchQuery.isNotEmpty) {
      regions = widget.regions
          .where((e) => e.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(slivers: [
        const ElapseAppBar(
          title: Row(children: [
            Text(
              "Filter by Region",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ]),
          backNavigation: true,
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
                          hintText: "Filter regions",
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
              final region = regions[index];
              bool selected = widget.filter.contains(region);
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
                                region,
                                style: const TextStyle(fontSize: 16),
                              ),
                              selected
                                  ? const Icon(Icons.check)
                                  : const SizedBox(),
                            ]),
                      ),
                      onTap: () {
                        setState(() {
                          selected
                              ? widget.filter.remove(region)
                              : widget.filter.add(region);
                        });
                      }),
                  index != regions.length - 1
                      ? Divider(
                          height: 3,
                          color: Theme.of(context).colorScheme.surfaceDim,
                        )
                      : Container(),
                ]),
              );
            },
            childCount: regions.length,
          ),
        ),
      ]),
    );
  }
}
