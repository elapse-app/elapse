import 'dart:io';

class ScoutSheetUI {
  String intakeType;
  String numMotors;
  String RPM;
  String otherNotes;

  List<File> photos;

  String autonNotes;

  ScoutSheetUI({
    required this.intakeType,
    required this.numMotors,
    required this.RPM,
    required this.otherNotes,
    required this.photos,
    required this.autonNotes,
  });
}
