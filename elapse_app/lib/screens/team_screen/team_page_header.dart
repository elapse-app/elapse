import 'package:flutter/material.dart';

/// Use the toolbar's leading/title slots, never overlay two back controls in
/// flexibleSpace. Their layout stays disjoint while scrolling and scaling text.
class TeamPageHeader extends StatelessWidget {
  const TeamPageHeader(
      {super.key, required this.teamNumber, required this.onSeason});
  final String teamNumber;
  final VoidCallback onSeason;

  @override
  Widget build(BuildContext context) => SliverAppBar(
        pinned: true,
        leading: BackButton(onPressed: () => Navigator.maybePop(context)),
        title: Text('Team $teamNumber',
            maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
              tooltip: 'Change season',
              onPressed: onSeason,
              icon: const Icon(Icons.event_note))
        ],
      );
}
