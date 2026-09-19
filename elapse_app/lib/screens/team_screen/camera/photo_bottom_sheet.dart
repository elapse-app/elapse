import 'dart:io';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

const int maxFileSize = 5 * 1024 * 1024; // 5 MB

Future<String?> getPhoto(
  BuildContext context, {
  required String teamGroupId,
}) async {
  File? image;
  XFile? imageData;
  String? imageURL;

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
                                                    .withValues(alpha: 0.5)),
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
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Uploading Photo"),
                                              content: Text(
                                                  "You will be navigated back once the photo is uploaded"),
                                            );
                                          },
                                        );
                                        try {
                                          imageURL = await uploadFile(
                                            imageData,
                                            teamGroupId: teamGroupId,
                                          );
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        } on Object {
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Photo upload failed. Try again.',
                                              ),
                                            ),
                                          );
                                        }
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
                            if (await File(returnedImage.path).length() <=
                                maxFileSize) {
                              setState(() {
                                imageData = returnedImage;
                                image = File(returnedImage.path);
                              });
                            } else {
                              _showSizeError(context);
                            }
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
                            if (await File(returnedImage.path).length() <=
                                maxFileSize) {
                              setState(() {
                                imageData = returnedImage;
                                image = File(returnedImage.path);
                              });
                            } else {
                              _showSizeError(context);
                            }
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
    return imageURL;
  });
}

void _showSizeError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'File size exceeds 5 MB. Please select a smaller image.',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    ),
  );
}

Future<String> uploadFile(
  XFile? pic, {
  required String teamGroupId,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (pic == null || uid == null || teamGroupId.isEmpty) {
    throw StateError('A signed-in team member is required to upload photos.');
  }

  final extension = p.extension(pic.name).toLowerCase();
  final contentType = switch (extension) {
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.heic' || '.heif' => 'image/heic',
    '.webp' => 'image/webp',
    _ => 'image/jpeg',
  };
  final safeName = p
      .basenameWithoutExtension(pic.name)
      .replaceAll(RegExp('[^a-zA-Z0-9_-]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  final uniqueName =
      '${DateTime.now().microsecondsSinceEpoch}-${safeName.isEmpty ? 'photo' : safeName}$extension';
  final path = 'teamGroups/$teamGroupId/scoutsheets/images/$uid/$uniqueName';
  final file = File(pic.path);

  final ref = FirebaseStorage.instance.ref().child(path);
  final snapshot = await ref.putFile(
    file,
    SettableMetadata(
      contentType: contentType,
      customMetadata: {
        'ownerUid': uid,
        'teamGroupId': teamGroupId,
      },
    ),
  );

  return await snapshot.ref.getDownloadURL();
}
