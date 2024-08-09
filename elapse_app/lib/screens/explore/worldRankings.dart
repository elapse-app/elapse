import 'package:elapse_app/screens/explore/worldRankings/worldSkills.dart';
import 'package:elapse_app/screens/explore/worldRankings/worldTrueSkill.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/rounded_top.dart';

class WorldRankingsScreen extends StatefulWidget {
  int initState = 0;
  WorldRankingsScreen({super.key, required this.initState});

  @override
  State<WorldRankingsScreen> createState() => _WorldRankingsState();
}

class _WorldRankingsState extends State<WorldRankingsScreen> {
  int selectedIndex = 0;
  List<String> titles = ["World Skills Ranking", "World TrueSkill Ranking"];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initState;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      WorldSkills(),
      WorldTrueSkill(),
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 125,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.only(top: 10),
                      constraints: BoxConstraints(),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      titles[selectedIndex],
                      style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ]
                )
              ),
              centerTitle: false,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverHeaderDelegate(
              minHeight: 70.0,
              maxHeight: 70.0,
              child: Hero(
                tag: "top",
                child: Stack(
                  children: [
                    Container(
                      height: 300,
                      color: Theme.of(context).colorScheme.primary
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                          ]
                        )
                      )
                    )
                  ]
                )
              )
            )
          )
        ]
      )
    );
  }
}