import 'dart:ui';

import 'package:elapse_app/classes/ScoutSheet/scoutSheetUi.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

List<Widget> ClosedState(BuildContext context, String teamNumber, ScoutSheetUI sheet, String teamID,
    String tournamentID, void Function() updateIndex) {
  Database database = Database();

  Widget photosDisplay = Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(9)), color: Theme.of(context).colorScheme.tertiary),
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
  if (sheet.photos.isNotEmpty) {
    photosDisplay = Row(children: [
      Expanded(
          child: StaggeredGrid.count(
        crossAxisCount: sheet.photos.length == 1
            ? 2
            : sheet.photos.length == 2
                ? 4
                : 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: Hero(
                tag: sheet.photos[0].hashCode,
                child: GestureDetector(
                    onTap: () => _openPhotoViewer(context, sheet.photos, 0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(sheet.photos[0], width: double.infinity, fit: BoxFit.cover,
                            loadingBuilder: (context, widget, progress) {
                          if (progress == null) return widget;
                          return Center(
                              child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                            ),
                          ));
                        })))),
          ),
          sheet.photos.length > 1
              ? StaggeredGridTile.count(
                  crossAxisCellCount: sheet.photos.length == 2 ? 2 : 1,
                  mainAxisCellCount: sheet.photos.length > 2 ? 1 : 2,
                  child: Hero(
                      tag: sheet.photos[1].hashCode,
                      child: GestureDetector(
                          onTap: () => _openPhotoViewer(context, sheet.photos, 1),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: Image.network(sheet.photos[1], width: double.infinity, fit: BoxFit.cover,
                                  loadingBuilder: (context, widget, progress) {
                                if (progress == null) return widget;
                                return Center(
                                    child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                                  ),
                                ));
                              })))))
              : const SizedBox.shrink(),
          sheet.photos.length > 2
              ? StaggeredGridTile.count(
                  crossAxisCellCount: 1,
                  mainAxisCellCount: 1,
                  child: Hero(
                      tag: sheet.photos[2].hashCode,
                      child: GestureDetector(
                          onTap: () => _openPhotoViewer(context, sheet.photos, 2),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
                              child: sheet.photos.length > 3
                                  ? Stack(children: [
                                      Image.network(sheet.photos[2], width: double.infinity, fit: BoxFit.cover,
                                          loadingBuilder: (context, widget, progress) {
                                        if (progress == null) return widget;
                                        return Center(
                                            child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                                          ),
                                        ));
                                      }),
                                      BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
                                          child: Container(
                                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)))),
                                      Center(
                                          child: DefaultTextStyle(
                                              style: const TextStyle(),
                                              child: Text("${sheet.photos.length - 2}+",
                                                  style: TextStyle(
                                                      fontSize: 48,
                                                      fontWeight: FontWeight.w600,
                                                      color: Theme.of(context).colorScheme.surface)))),
                                    ])
                                  : Image.network(sheet.photos[2], width: double.infinity, fit: BoxFit.cover,
                                      loadingBuilder: (context, widget, progress) {
                                      if (progress == null) return widget;
                                      return Center(
                                          child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          value: progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                                        ),
                                      ));
                                    })))))
              : const SizedBox.shrink(),
        ],
      ))
    ]);
  }

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
            Text(sheet.intakeType, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text("Intake Type", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  )
                : SizedBox(),
            sheet.otherNotes != "" ? SizedBox(height: 12) : SizedBox(),
            sheet.otherNotes != "" ? Text(sheet.otherNotes, style: TextStyle(fontSize: 16)) : SizedBox(),
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
            Text(sheet.autonNotes != "" ? sheet.autonNotes : "No notes provided", style: TextStyle(fontSize: 16)),
          ],
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
                    content: Text("Are you sure you want to delete this scoutsheet?"),
                    actions: [
                      TextButton(
                        onPressed: updateIndex,
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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

void _openPhotoViewer(BuildContext context, List<dynamic> photos, int initIndex) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(color: Colors.black),
            padding: const EdgeInsets.only(top: 50),
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: Stack(alignment: AlignmentDirectional.topEnd, children: [
              PhotoViewGallery.builder(
                itemCount: photos.length,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(photos[index]),
                    initialScale: PhotoViewComputedScale.contained,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: index > 2 ? photos[2].hashCode : photos[index].hashCode),
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    value: event != null ? event.cumulativeBytesLoaded / event.expectedTotalBytes! : null,
                  ),
                )),
                pageController: PageController(initialPage: initIndex),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white, size: 50),
              )
            ])));
  }));
}
