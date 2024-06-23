import 'package:elapse_app/screens/settings/settings.dart';
import 'package:flutter/material.dart';

class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({super.key});

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
                  title: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 12),
                    child: Text(
                      "My Team",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
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
