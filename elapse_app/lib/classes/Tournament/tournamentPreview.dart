import 'package:elapse_app/classes/Miscellaneous/location.dart';

class TournamentPreview {
  int id;
  String name;
  String? sku;
  Location? location;
  DateTime? startDate;
  DateTime? endDate;

  TournamentPreview({
    required this.id,
    required this.name,
    this.location,
    this.startDate,
    this.endDate,
  });
}
