import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/division.dart';

class Tournament {
  int id;

  int seasonID;
  String name;

  Location location;

  DateTime startDate;
  DateTime? endDate;

  List<Division> divisions;
  List<Team> teams;

  Tournament({
    required this.id,
    required this.name,
    required this.seasonID,
    required this.location,
    required this.startDate,
    required this.divisions,
    required this.teams,
    this.endDate,
  });
}
