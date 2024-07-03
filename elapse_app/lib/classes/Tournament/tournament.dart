import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';

class Tournament {
  int id;

  int seasonID;
  String name;

  Location location;

  DateTime startDate;
  DateTime? endDate;

  List<Division> divisions;

  Tournament({
    required this.id,
    required this.name,
    required this.seasonID,
    required this.location,
    required this.startDate,
    required this.divisions,
    this.endDate,
  });
}
