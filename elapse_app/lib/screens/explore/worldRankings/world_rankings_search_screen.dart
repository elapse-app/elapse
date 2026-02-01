import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills_widget.dart';
import 'package:elapse_app/screens/widgets/custom_tab_bar.dart';
import 'package:flutter/material.dart';

import '../../../classes/Team/world_skills.dart';

class WorldRankingsSearchScreen extends StatefulWidget {
  const WorldRankingsSearchScreen({
    super.key,
    required this.skills,
  });

  final List<WorldSkillsStats> skills;

  @override
  State<WorldRankingsSearchScreen> createState() => _WorldRankingsSearchScreenState();
}

class _WorldRankingsSearchScreenState extends State<WorldRankingsSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<WorldSkillsStats> filteredSkills = widget.skills.where((e) {
      return (e.teamName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          e.teamNum.toLowerCase().contains(searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 90,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      num containerHeight = constraints.maxHeight;
                      return Container(
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_back, size: 24),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                Flexible(
                                    flex: 6,
                                    child: TextField(
                                      focusNode: _focusNode,
                                      onChanged: (value) {
                                        setState(() {
                                          searchQuery = value;
                                        });
                                      },
                                      cursorColor: Theme.of(context).colorScheme.secondary,
                                      decoration: const InputDecoration(
                                        hintText: "Search world rankings",
                                        border: InputBorder.none,
                                      ),
                                    ))
                              ]),
                        ),
                      );
                    },
                  ),
                ),
              ),
              centerTitle: false,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverHeaderDelegate(
              maxHeight: 25,
              minHeight: 25,
              child: Hero(
                tag: "top",
                child: Stack(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.primary,
                      height: 25,
                    ),
                    Container(
                      height: 25,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Skills", style: TextStyle(fontSize: 16)),
                  Divider(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    thickness: 1.5,
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ranking = filteredSkills[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Column(
                    children: [
                      WorldSkillsWidget(stats: ranking, rank: index + 1),
                      index != filteredSkills.length - 1
                          ? Divider(
                              height: 3,
                              color: Theme.of(context).colorScheme.surfaceDim,
                            )
                          : Container(),
                    ],
                  ),
                );
              },
              childCount: filteredSkills.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 15,
            ),
          ),
        ],
      ),
    );
  }
}
