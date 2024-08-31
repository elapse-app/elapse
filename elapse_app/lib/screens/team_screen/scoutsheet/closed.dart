import 'package:flutter/material.dart';

List<Widget> ClosedState(
    BuildContext context, void Function() buttonAction, String teamNumber) {
  return [
    SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 10, left: 23, right: 23),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${teamNumber} Specs", style: TextStyle(fontSize: 24)),
            SizedBox(height: 18),
            Text("Hook Intake",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text("Intake Type",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
            SizedBox(height: 12),
            Divider(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "6",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text("# of Motors", style: TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "450",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text("RPM", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
            ),
            SizedBox(height: 12),
            Text(
                "They have a PTO mechanism that shifts 2 of their drivetrain motors to their wall stake mechanism",
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 9),
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        margin: EdgeInsets.only(left: 23, right: 23, top: 15),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Photos", style: TextStyle(fontSize: 24)),
            SizedBox(
              height: 18,
            ),
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  child: Container(
                    height: 175,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                SizedBox(width: 12),
                Flexible(
                  child: Container(
                    height: 175,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context).colorScheme.primary),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        margin: EdgeInsets.only(
          left: 23,
          right: 23,
          top: 15,
        ),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Auton Notes", style: TextStyle(fontSize: 24)),
            SizedBox(
              height: 18,
            ),
            Text("They have a rush auton, an AWP auton and a 4 ring auton",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 30, left: 23, right: 23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("Scouted Matches", style: TextStyle(fontSize: 24))],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 15, left: 23, right: 23),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text("All Matches", style: TextStyle(fontSize: 24))],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).padding.bottom,
      ),
    )
  ];
}
