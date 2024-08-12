import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';

class TournamentLoadingScreen extends StatelessWidget {
  const TournamentLoadingScreen({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 125,
            centerTitle: false,
            flexibleSpace: const FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: EdgeInsets.only(left: 20.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [],
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
                        children: [Spacer()],
                      ),
                    ],
                  ),
                ),
              ),
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
                          color: Theme.of(context).colorScheme.primary),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(),
          )
        ],
      ),
    );
  }
}
