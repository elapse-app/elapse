import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/division.dart';

class Tournament {
  int id;

  int seasonID;

  Location location;

  DateTime startDate;
  DateTime? endDate;

  List<Division> divisions;

  Tournament({
    required this.id,
    required this.seasonID,
    required this.location,
    required this.startDate,
    required this.divisions,
    this.endDate,
  });
}
