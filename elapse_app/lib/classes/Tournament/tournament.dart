import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/division.dart';

class Tournament {
  int id;

  List<List<Match>> schedule;
  List<Team> teams;
  List<Award> awards;

  int seasonID;

  Location location;

  DateTime startDate;
  DateTime? endDate;

  List<Division> divisions;

  Tournament({
    required this.id,
    required this.schedule,
    required this.seasonID,
    required this.teams,
    required this.awards,
    required this.location,
    required this.startDate,
    required this.divisions,
    this.endDate,
  });
}
