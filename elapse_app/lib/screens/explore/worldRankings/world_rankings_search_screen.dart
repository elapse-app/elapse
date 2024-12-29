import 'package:elapse_app/screens/explore/worldRankings/skills/world_skills_widget.dart';
import 'package:elapse_app/screens/explore/worldRankings/true_skill/world_true_skill_widget.dart';
import 'package:flutter/material.dart';

import '../../../classes/Team/vdaStats.dart';
import '../../../classes/Team/world_skills.dart';
import '../../widgets/custom_tab_bar.dart';

class WorldRankingsSearchScreen extends StatefulWidget {
  const WorldRankingsSearchScreen({
    super.key,
    required this.skills,
    required this.vda,
  });

  final List<WorldSkillsStats> skills;
  final List<VDAStats> vda;

  @override
<<<<<<< HEAD
  State<WorldRankingsSearchScreen> createState() =>
      _WorldRankingsSearchScreenState();
=======
  State<WorldRankingsSearchScreen> createState() => _WorldRankingsSearchScreenState();
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
}

class _WorldRankingsSearchScreenState extends State<WorldRankingsSearchScreen> {
  final FocusNode _focusNode = FocusNode();
  int selectedIndex = 0;
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
    List<VDAStats> filteredVDA = widget.vda.where((e) {
<<<<<<< HEAD
      return ((e.teamName ?? "")
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
=======
      return ((e.teamName ?? "").toLowerCase().contains(searchQuery.toLowerCase()) ||
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
          e.teamNum.toLowerCase().contains(searchQuery.toLowerCase()));
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 165,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      num containerHeight = constraints.maxHeight;
                      return Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Spacer(),
                              Flex(
                                  direction: Axis.horizontal,
<<<<<<< HEAD
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
=======
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: IconButton(
<<<<<<< HEAD
                                        icon: const Icon(Icons.arrow_back,
                                            size: 24),
=======
                                        icon: const Icon(Icons.arrow_back, size: 24),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
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
<<<<<<< HEAD
                                          cursorColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
=======
                                          cursorColor: Theme.of(context).colorScheme.secondary,
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                                          decoration: const InputDecoration(
                                            hintText: "Search world rankings",
                                            border: InputBorder.none,
                                          ),
                                        ))
                                  ]),
                              const Spacer(),
                              if (constraints.maxHeight - 135 + 45 > 0)
                                SizedBox(
<<<<<<< HEAD
                                    height: containerHeight > 130
                                        ? 45
                                        : containerHeight - 130 + 45,
                                    child: Flex(
                                        direction: Axis.horizontal,
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: _filterButton(0,
                                                constraints.maxHeight, "All"),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: _filterButton(
                                                1,
                                                constraints.maxHeight,
                                                "Skills"),
                                          ),
                                          Flexible(
                                            flex: 1,
                                            child: _filterButton(
                                                2,
                                                constraints.maxHeight,
                                                "TrueSkill"),
                                          ),
                                        ]))
=======
                                    height: containerHeight > 130 ? 45 : containerHeight - 130 + 45,
                                    child: Flex(direction: Axis.horizontal, children: [
                                      Flexible(
                                        flex: 1,
                                        child: _filterButton(0, constraints.maxHeight, "All"),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: _filterButton(1, constraints.maxHeight, "Skills"),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: _filterButton(2, constraints.maxHeight, "TrueSkill"),
                                      ),
                                    ]))
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                              else
                                const Spacer(),
                              const Spacer(),
                            ],
                          ),
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
          selectedIndex == 0 || selectedIndex == 1
              ? SliverPadding(
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
                )
              : const SliverToBoxAdapter(),
          selectedIndex == 0 || selectedIndex == 1
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ranking = filteredSkills[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: Column(
                          children: [
<<<<<<< HEAD
                            WorldSkillsWidget(stats: ranking),
                            index != filteredSkills.length - 1
                                ? Divider(
                                    height: 3,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
=======
                            WorldSkillsWidget(stats: ranking, rank: index + 1),
                            index != filteredSkills.length - 1
                                ? Divider(
                                    height: 3,
                                    color: Theme.of(context).colorScheme.surfaceDim,
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    },
                    childCount: filteredSkills.length,
                  ),
                )
              : const SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: selectedIndex == 0
                ? const SizedBox(
                    height: 15,
                  )
                : null,
          ),
          selectedIndex == 0 || selectedIndex == 2
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TrueSkill", style: TextStyle(fontSize: 16)),
                        Divider(
                          color: Theme.of(context).colorScheme.surfaceDim,
                          thickness: 1.5,
                        ),
                      ],
                    ),
                  ),
                )
              : const SliverToBoxAdapter(),
          selectedIndex == 0 || selectedIndex == 2
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final stats = filteredVDA[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: Column(
                          children: [
<<<<<<< HEAD
                            WorldTrueSkillWidget(stats: stats),
                            index != filteredVDA.length - 1
                                ? Divider(
                                    height: 3,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceDim,
=======
                            WorldTrueSkillWidget(stats: stats, rank: index + 1),
                            index != filteredVDA.length - 1
                                ? Divider(
                                    height: 3,
                                    color: Theme.of(context).colorScheme.surfaceDim,
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    },
                    childCount: filteredVDA.length,
                  ),
                )
              : const SliverToBoxAdapter(),
        ],
      ),
    );
  }

  Widget _filterButton(buttonIndex, maxHeight, text) {
    Color selectedContainerColor = Theme.of(context).colorScheme.primary;
    Color unselectedContainerColor = Theme.of(context).colorScheme.surface;

    BorderRadius borderRadius;

    if (buttonIndex == 0) {
      borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      );
    } else if (buttonIndex == 2) {
      borderRadius = const BorderRadius.only(
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    } else {
      borderRadius = BorderRadius.zero;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = buttonIndex;
        });
      },
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
<<<<<<< HEAD
        duration:
            const Duration(milliseconds: 300), // Duration of the animation
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedIndex == buttonIndex
              ? selectedContainerColor.withOpacity(
                  ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)
              : unselectedContainerColor.withOpacity(
                  ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
=======
        duration: const Duration(milliseconds: 300), // Duration of the animation
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selectedIndex == buttonIndex
              ? selectedContainerColor.withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40)
              : unselectedContainerColor.withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
          border: buttonIndex == 1
              ? Border.symmetric(
                  horizontal: BorderSide(
                    width: 1.5,
<<<<<<< HEAD
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                        ((maxHeight - 85) / 40) > 1
                            ? 1
                            : (maxHeight - 85) / 40),
=======
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                  ),
                )
              : Border.all(
                  width: 1.5,
<<<<<<< HEAD
                  color: Theme.of(context).colorScheme.primary.withOpacity(
                      ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
=======
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
                ),
          borderRadius: borderRadius,
        ),
        child: Text(
          text,
          style: TextStyle(
<<<<<<< HEAD
            color: Theme.of(context).colorScheme.secondary.withOpacity(
                ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
=======
            color: Theme.of(context)
                .colorScheme
                .secondary
                .withValues(alpha: ((maxHeight - 85) / 40) > 1 ? 1 : (maxHeight - 85) / 40),
>>>>>>> dbed9adbabfc43517d099a5b670964e9a9abba77
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
