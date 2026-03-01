// Validation utilities for sanitizing data before SQLite storage.
import 'package:flutter/foundation.dart';

class IngestionError {
  final String field;
  final String message;
  final dynamic rawValue;
  final DateTime timestamp;

  IngestionError({
    required this.field,
    required this.message,
    this.rawValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'IngestionError($field): $message';
}

class IngestionResult<T> {
  final T? data;
  final List<IngestionError> errors;
  final bool partial;

  IngestionResult({
    this.data,
    this.errors = const [],
    this.partial = false,
  });

  bool get success => data != null && errors.isEmpty;
  bool get hasData => data != null;
}

/// Validates tournament data before SQLite storage.
/// Converts Tournament.toJson() output to SQLite-compatible format.
class TournamentValidator {
  /// Validates and sanitizes tournament JSON before storage.
  /// Returns sanitized data ready for SQLite insertion.
  /// Throws if tournament ID is missing (required).
  static Map<String, dynamic> validate(Map<String, dynamic> json) {
    final warnings = <String>[];

    // Required field - tournament ID
    final id = _parseInt(json['id'], 'id', warnings);
    if (id == null) {
      throw Exception('Tournament ID is required');
    }

    // Optional fields with defaults
    final name = json['name']?.toString() ?? 'Unknown Tournament';
    final sku = json['sku']?.toString() ?? '';
    final seasonId = json['seasonID'] ?? json['season_id'] ?? 0;

    // Dates - handle both API format and toJson() format
    final startDate = _parseDate(json['start']) ?? _parseDate(json['startDate']);
    final endDate = _parseDate(json['end']) ?? _parseDate(json['endDate']);

    // Location - handle nested structure from toJson()
    Map<String, dynamic> location = {};
    if (json['location'] is Map) {
      location = json['location'] as Map<String, dynamic>;
    }

    if (warnings.isNotEmpty && kDebugMode) {
      debugPrint('Tournament validation warnings for ID $id: $warnings');
    }

    return {
      'id': id,
      'name': name,
      'sku': sku,
      'season_id': seasonId is int ? seasonId : int.tryParse(seasonId.toString()) ?? 0,
      'start_date': startDate?.toIso8601String() ?? '',
      'end_date': endDate?.toIso8601String(),
      'venue': location['venue']?.toString(),
      'city': location['city']?.toString(),
      'region': location['region']?.toString(),
      'country': location['country']?.toString(),
      'address1': (location['address_1'] ?? location['address1'])?.toString(),
      'address2': (location['address_2'] ?? location['address2'])?.toString(),
      'postal_code': (location['postcode'] ?? location['postalCode'])?.toString(),
    };
  }

  static int? _parseInt(dynamic value, String field, List<String> warnings) {
    if (value == null) {
      warnings.add('$field is null');
      return null;
    }
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    warnings.add('$field cannot be parsed as int: $value');
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}
