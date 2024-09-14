import 'package:elapse_app/classes/ScoutSheet/scoutSheetUi.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:flutter/material.dart';

List<Widget> ClosedState(
    BuildContext context,
    String teamNumber,
    ScoutSheetUI sheet,
    String teamID,
    String teamGroupID,
    String tournamentID,
    void Function() updateIndex) {
  Database database = Database();
  Widget photosDisplay = Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(9)),
        color: Theme.of(context).colorScheme.tertiary),
    height: 175,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text("No Photos uploaded")],
        ),
      ],
    ),
  );

  // if (sheet.photos.length == 1) {
  //   photosDisplay = ClipRRect(
  //     borderRadius: BorderRadius.circular(9),
  //     child: Image.file(
  //       sheet.photos[0],
  //       height: 175,
  //       width: double.infinity,
  //       fit: BoxFit.cover,
  //     ),
  //   );
  // } else if (sheet.photos.length == 2) {
  //   photosDisplay = Flex(
  //     direction: Axis.horizontal,
  //     children: [
  //       Flexible(
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(9),
  //           child: Image.file(
  //             sheet.photos[0],
  //             height: 175,
  //             width: double.infinity,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //       SizedBox(width: 9),
  //       Flexible(
  //         child: ClipRRect(
  //           borderRadius: BorderRadius.circular(9),
  //           child: Image.file(
  //             sheet.photos[1],
  //             height: 175,
  //             width: double.infinity,
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  return [
    SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 8, left: 23, right: 23),
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
            Text(sheet.intakeType,
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
                      sheet.numMotors,
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
                      sheet.RPM,
                      style: TextStyle(fontSize: 16),
                    ),
                    Text("RPM", style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            sheet.otherNotes != ""
                ? Divider(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2),
                  )
                : SizedBox(),
            sheet.otherNotes != "" ? SizedBox(height: 12) : SizedBox(),
            sheet.otherNotes != ""
                ? Text("Nice", style: TextStyle(fontSize: 16))
                : SizedBox(),
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
            photosDisplay
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
            Text(
                sheet.autonNotes != "" ? sheet.autonNotes : "No notes provided",
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
      child: Container(
        margin: EdgeInsets.only(top: 15, left: 23, right: 23),
        child: TextButton(
            child: Text(
              "Delete ScoutSheet",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text("Confirm Deletion"),
                    content: Text(
                        "Are you sure you want to delete this scoutsheet?"),
                    actions: [
                      TextButton(
                        onPressed: updateIndex,
                        child: Text(
                          "Delete",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      )
                    ],
                  );
                },
              );
            }),
      ),
    ),
    SliverToBoxAdapter(
      child: SizedBox(
        height: MediaQuery.of(context).padding.bottom,
      ),
    )
  ];
}
