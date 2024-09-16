import 'dart:io';

import 'package:elapse_app/classes/ScoutSheet/scoutSheetUi.dart';
import 'package:elapse_app/screens/team_screen/camera/camera.dart';
import 'package:elapse_app/screens/team_screen/camera/photo_bottom_sheet.dart';
import 'package:flutter/material.dart';

List<Widget> EditState(
  BuildContext context,
  String teamNumber,
  void Function(String) addPhoto,
  void Function(int) removePhoto,
  List<dynamic> photos,
  void Function(String property, String value) updateProperty,
  ScoutSheetUI sheet,
) {

  Widget photosDisplay = GestureDetector(
    onTap: () async {
      final result = await getPhoto(context);
      if (result != null) {
        addPhoto(result);
        print(photos.length);
      }
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
  );

  if (photos.length == 1) {
    photosDisplay = Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  photos[0],
                  height: 175,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5)),
                  ),
                  IconButton(
                      onPressed: () {
                        removePhoto(0);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 9),
        Flexible(child: photosDisplay)
      ],
    );
  } else if (photos.length == 2) {
    photosDisplay = Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  photos[0],
                  height: 175,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5)),
                  ),
                  IconButton(
                      onPressed: () {
                        removePhoto(0);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 9),
        Flexible(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  photos[1],
                  height: 175,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5)),
                  ),
                  IconButton(
                      onPressed: () {
                        removePhoto(1);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
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
            TextFormField(
              decoration: ElapseInputDecoration(context, "Intake Type"),
              onChanged: (value) {
                updateProperty("intakeType", value);
              },
              initialValue: sheet.intakeType,
            ),
            SizedBox(height: 18),
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: TextFormField(
                    decoration: ElapseInputDecoration(context, "# of DT Motors"),
                    onChanged: (value) {
                      updateProperty("numMotors", value);
                    },
                    initialValue: sheet.numMotors,
                  ),
                ),
                SizedBox(width: 9),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: TextFormField(
                    decoration: ElapseInputDecoration(context, "DT RPM"),
                    onChanged: (value) {
                      updateProperty("RPM", value);
                    },
                    initialValue: sheet.RPM,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 18,
            ),
            TextFormField(
              maxLines: 5,
              decoration: ElapseInputDecoration(context, "Other Notes"),
              onChanged: (value) {
                updateProperty("otherNotes", value);
              },
              initialValue: sheet.otherNotes,
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
            TextFormField(
              maxLines: 8,
              decoration: ElapseInputDecoration(context, "Enter Notes"),
              onChanged: (value) {
                updateProperty("autonNotes", value);
              },
              initialValue: sheet.autonNotes,
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

InputDecoration ElapseInputDecoration(BuildContext context, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(fontWeight: FontWeight.w500),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(9)),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.surfaceDim,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(9)),
      borderSide:
      BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
    ),
  );
}
