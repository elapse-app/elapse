import 'package:elapse_app/classes/Miscellaneous/location.dart';

class Team {
  int id;
  String teamName;
  String teamNumber;
  String organization;
  Location location;
  String grade;

  Team({
    required this.id,
    required this.teamName,
    required this.teamNumber,
    required this.organization,
    required this.location,
    required this.grade,
  });
}
