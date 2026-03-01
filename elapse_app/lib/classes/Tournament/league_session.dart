import 'package:elapse_app/classes/Miscellaneous/location.dart';

/// Represents a single session within a VEX league event.
/// Leagues have multiple session dates, potentially at different locations.
class LeagueSession {
  final DateTime date;
  final Location location;

  LeagueSession({
    required this.date,
    required this.location,
  });

  /// Creates a LeagueSession from a Map entry where:
  /// - key is the date string (e.g., "2025-11-04")
  /// - value is the location object
  factory LeagueSession.fromMapEntry(String dateKey, Map<String, dynamic> locationJson) {
    // Parse date with fallback for malformed data
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(dateKey);
    } catch (e) {
      // Fallback to epoch if date parsing fails
      parsedDate = DateTime.fromMillisecondsSinceEpoch(0);
    }

    return LeagueSession(
      date: parsedDate,
      location: Location(
        venue: locationJson['venue'],
        city: locationJson['city'],
        region: locationJson['region'],
        country: locationJson['country'],
        address1: locationJson['address_1'],
        address2: locationJson['address_2'],
        postalCode: locationJson['postcode'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'location': location.toJson(),
  };

  /// Loads a LeagueSession from cached JSON format
  factory LeagueSession.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'] as Map<String, dynamic>?;

    return LeagueSession(
      date: DateTime.parse(json['date']),
      location: Location(
        venue: locationData?['venue'],
        city: locationData?['city'],
        region: locationData?['region'],
        country: locationData?['country'],
        address1: locationData?['address_1'],
        address2: locationData?['address_2'],
        postalCode: locationData?['postcode'],
      ),
    );
  }

  /// Equality based on date (sessions are unique by date)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeagueSession &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day;
  }

  @override
  int get hashCode => date.year.hashCode ^ date.month.hashCode ^ date.day.hashCode;
}
