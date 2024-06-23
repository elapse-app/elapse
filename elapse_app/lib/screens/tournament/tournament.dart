import 'package:elapse_app/screens/settings/settings.dart';
import 'package:flutter/material.dart';

class TournamentScreen extends StatelessWidget {
  const TournamentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Container(height: 300, color: Theme.of(context).colorScheme.primary),
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                automaticallyImplyLeading: false,
                expandedHeight: 125,
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.parallax,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Schedule",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            size: 30,
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                  ),
                  centerTitle: false,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 12, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton(
                                value: "Division 1",
                                borderRadius: BorderRadius.circular(20),
                                items: const [
                                  DropdownMenuItem(
                                      value: "Division 1",
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.groups_3_outlined,
                                            size: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Division 1"),
                                        ],
                                      )),
                                  DropdownMenuItem(
                                      value: "Division 2",
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.groups_3_outlined,
                                            size: 30,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Division 2"),
                                        ],
                                      )),
                                ],
                                onChanged: (value) => {},
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.account_circle_rounded,
                                  weight: 0.1,
                                ),
                                iconSize: 30,
                                color: Theme.of(context).colorScheme.onSurface,
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (context) => SettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  height: 1000,
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
