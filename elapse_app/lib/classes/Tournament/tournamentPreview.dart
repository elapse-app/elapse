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

  factory TournamentPreview.fromJson(Map<String, dynamic> json) {
    Location location = new Location(
        address1: json['address_1'],
        address2: json['address_2'],
        city: json['city'],
        region: json['region'],
        country: json['country'],
        venue: json['venue']);
    return TournamentPreview(
      id: json['id'],
      name: json['name'],
      location: location,
      startDate: DateTime.parse(json['start']),
      endDate: DateTime.parse(json['end']),
    );
  }
}
