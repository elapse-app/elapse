import 'package:elapse_app/screens/team_screen/camera/camera.dart';
import 'package:flutter/material.dart';

List<Widget> EditState(BuildContext context, String teamNumber) {
  InputDecoration ElapseInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(9)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.surfaceDim,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(9)),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  return [
    SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        margin: EdgeInsets.only(left: 23, right: 23, top: 8),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${teamNumber} Specs",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 18),
            TextField(
              decoration: ElapseInputDecoration("Intake Type"),
            ),
            SizedBox(height: 18),
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: TextField(
                    decoration: ElapseInputDecoration("# of Motors"),
                  ),
                ),
                SizedBox(width: 9),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: TextField(
                    decoration: ElapseInputDecoration("RPM"),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 18,
            ),
            TextField(
              maxLines: 5,
              decoration: ElapseInputDecoration("Other Notes"),
            ),
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
            Text(
              "Photos",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: 18,
            ),
            GestureDetector(
              onTap: () {
                takePicture(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(9)),
                    color: Theme.of(context).colorScheme.tertiary),
                height: 175,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined),
                        SizedBox(height: 5),
                        Text("Add Photo")
                      ],
                    ),
                  ],
                ),
              ),
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
        margin: EdgeInsets.only(left: 23, right: 23, top: 15),
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Auton Notes",
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: 18,
            ),
            TextField(
              maxLines: 8,
              decoration: ElapseInputDecoration("Enter Notes"),
            ),
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.only(top: 35, left: 23, right: 23),
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
