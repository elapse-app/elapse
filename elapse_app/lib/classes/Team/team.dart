import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/seasonStats.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';

class Team {
  int id;
  String? teamName;
  String? teamNumber;
  String? organization;
  Location? location;
  String? grade;
  SeasonStats? seasonStats;
  TeamStats? tournamentStats;

  Team(
      {required this.id,
      required this.teamName,
      required this.teamNumber,
      required this.organization,
      required this.location,
      required this.grade,
      this.seasonStats,
      this.tournamentStats});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json["id"],
      teamName: json["team_name"],
      teamNumber: json["number"],
      organization: json["organization"],
      location: Location(
          city: json["city"],
          region: json["region"],
          address1: json["address_1"],
          address2: json["address_2"],
          country: json["country"]),
      grade: json["grade"],
    );
  }
}
