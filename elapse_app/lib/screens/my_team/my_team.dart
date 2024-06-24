import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';

class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar.large(
                automaticallyImplyLeading: false,
                expandedHeight: 125,
                centerTitle: false,
                flexibleSpace: const FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.parallax,
                  title: Padding(
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
                      padding: EdgeInsets.only(left: 20, right: 12, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Spacer(),
                              SettingsButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              const RoundedTop(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return ListTile(
                      tileColor: Theme.of(context).colorScheme.surface,
                      title: Text('Item #$index'),
                    );
                  },
                  childCount:
                      5, // Replace with the number of items in your list
                ),
              ),
              SliverFillRemaining(
                fillOverscroll: true,
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
