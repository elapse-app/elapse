import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/settings/settings.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 200,
            centerTitle: false,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var top = constraints.biggest.height;
                double sizedBoxHeight = (top - kToolbarHeight) * 0.65 -
                    MediaQuery.of(context).viewPadding.top;
                sizedBoxHeight = sizedBoxHeight < 0 ? 0 : sizedBoxHeight;
                return FlexibleSpaceBar(
                  expandedTitleScale: 1,
                  collapseMode: CollapseMode.parallax,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Spacer(),
                        const Text(
                          "Good Afternoon",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: sizedBoxHeight,
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
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0),
                                    child: Icon(Icons.search,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary),
                                  ),
                                  Text("Search for anything",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
              childCount: 5, // Replace with the number of items in your list
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
    );
  }
}
