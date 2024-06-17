import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';

class Tournament {
  List<Match> schedule;
  List<Team> teams;
  List<Award> awards;

  Location location;
  String venue;
  String address1;
  String address2;

  DateTime startDate;
  DateTime? endDate;

  Tournament({
    required this.schedule,
    required this.teams,
    required this.awards,
    required this.location,
    required this.venue,
    required this.address1,
    required this.address2,
    required this.startDate,
    this.endDate,
  });
}
