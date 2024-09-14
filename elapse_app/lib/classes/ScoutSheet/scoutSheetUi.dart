import 'dart:io';

class ScoutSheetUI {
  String intakeType;
  String numMotors;
  String RPM;
  String otherNotes;

  List<String> photos;

  String autonNotes;

  ScoutSheetUI({
    required this.intakeType,
    required this.numMotors,
    required this.RPM,
    required this.otherNotes,
    required this.photos,
    required this.autonNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      "intakeType": intakeType,
      "numMotors": numMotors,
      "RPM": RPM,
      "otherNotes": otherNotes,
      "photos": photos,
      "autonNotes": autonNotes
    };
  }
}
