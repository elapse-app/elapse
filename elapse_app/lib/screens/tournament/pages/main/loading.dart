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
                              _buildIconButton(context, Icons.schedule, 0),
                              _buildIconButton(context,
                                  Icons.format_list_numbered_outlined, 1),
                              _buildIconButton(
                                  context, Icons.sports_esports_outlined, 2),
                              _buildIconButton(context, Icons.info_outlined, 3),
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

  Widget _buildIconButton(BuildContext context, IconData icon, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
        ),
        IconButton(
          icon: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () async {},
        ),
      ],
    );
  }
}
