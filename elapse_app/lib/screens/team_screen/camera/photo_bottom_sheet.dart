import 'dart:io';

import 'package:elapse_app/aesthetics/color_schemes.dart';
import 'package:elapse_app/extras/database.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> getPhoto(BuildContext context) async {
  Color redColor = Theme.of(context).brightness == Brightness.light
      ? lightPallete.redAllianceText
      : darkPallete.redAllianceText;

  File? image;
  Database database = Database();
  return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.8,
            maxChildSize: 0.8,
            minChildSize: 0.25,
            expand: false,
            shouldCloseOnMinExtent: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                  padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(18)),
                            alignment: Alignment.center,
                            height: image == null ? 250 : null,
                            child: image != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Image.file(
                                          image!,
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
                                                color: Colors.black
                                                    .withOpacity(0.5)),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                image = null;
                                              });
                                            },
                                            icon: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : Text("Image preview will be displayed here"),
                          ),
                          image != null ? SizedBox(height: 18) : Container(),
                          image != null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: Icon(Icons.upload_outlined),
                                      label: Text("Upload"),
                                    ),
                                  ],
                                )
                              : Container()
                        ],
                      ),
                      SizedBox(height: 36),
                      LongButton(
                        onPressed: () async {
                          final returnedImage = await ImagePicker()
                              .pickImage(source: ImageSource.camera);
                          if (returnedImage != null) {
                            image = File(returnedImage.path);
                            await database.uploadPhoto(image!);
                            setState(() {
                              image = File(returnedImage.path);
                            });
                          }
                        },
                        text: "Take Photo",
                        icon: Icons.photo_camera_outlined,
                      ),
                      SizedBox(height: 18),
                      LongButton(
                        onPressed: () async {
                          final returnedImage = await ImagePicker()
                              .pickImage(source: ImageSource.gallery);

                          if (returnedImage != null) {
                            image = File(returnedImage.path);
                            await database.uploadPhoto(image!);
                            setState(() {
                              image = File(returnedImage.path);
                            });
                          }
                        },
                        text: "Select from Gallery",
                        icon: Icons.photo_outlined,
                      ),
                      SizedBox(height: 36),
                    ],
                  ));
            },
          );
        });
      }).then((_) {
    return image;
  });
}
