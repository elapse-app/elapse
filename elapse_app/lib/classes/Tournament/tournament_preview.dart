import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/extras/async_cache.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;

import '../../screens/explore/filters.dart';

class TournamentPreview {
  final int id;
  final String name;
  final String? sku;
  final Location? location;
  final DateTime? startDate;
  final DateTime? endDate;

  TournamentPreview({
    required this.id,
    required this.name,
    this.sku,
    this.location,
    this.startDate,
    this.endDate,
  });

  factory TournamentPreview.fromJson(Map<String, dynamic> json) {
    final locationJson = json['location'];
    return TournamentPreview(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      sku: json['sku'] as String?,
      location: locationJson is Map<String, dynamic>
          ? Location(
              address1: locationJson['address_1'],
              address2: locationJson['address_2'],
              city: locationJson['city'],
              region: locationJson['region'],
              country: locationJson['country'],
              venue: locationJson['venue'],
            )
          : null,
      startDate: DateTime.tryParse(json['start']?.toString() ?? ''),
      endDate: DateTime.tryParse(json['end']?.toString() ?? ''),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TournamentPreview && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class TournamentList {
  final List<TournamentPreview> tournaments;
  final int maxPage;

  TournamentList({required this.tournaments, required this.maxPage});
}

final _teamTournamentCache = AsyncCache<String, List<TournamentPreview>>(
  timeToLive: const Duration(minutes: 5),
);

Future<List<TournamentPreview>> fetchTeamTournaments(
  int teamId,
  int seasonID, {
  bool forceRefresh = false,
}) {
  return _teamTournamentCache.get(
    '$teamId:$seasonID',
    () => _fetchTeamTournaments(teamId, seasonID),
    forceRefresh: forceRefresh,
  );
}

Future<List<TournamentPreview>> _fetchTeamTournaments(
  int teamId,
  int seasonID,
) async {
  final loadedTournamentInfo = await http.get(
    Uri.parse(
        "https://events.vex.com/api/v2/teams/$teamId/events?season%5B%5D=$seasonID&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
      HttpHeaders.acceptHeader: 'application/json',
    },
  ).timeout(const Duration(seconds: 12));

  if (loadedTournamentInfo.statusCode != 200) {
    throw Exception(
      'Failed to load team tournaments (${loadedTournamentInfo.statusCode})',
    );
  }

  final decoded = jsonDecode(loadedTournamentInfo.body);
  if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
    throw const FormatException('Unexpected VEX team events response.');
  }
  final parsedTournamentInfo = decoded['data'] as List;
  final tournaments = parsedTournamentInfo
      .whereType<Map<String, dynamic>>()
      .map(TournamentPreview.fromJson)
      .toList()
    ..sort(_compareTournamentDates);

  return List.unmodifiable(tournaments);
}

/// Returns a sorted copy and never mutates the API result shared by callers.
List<TournamentPreview> upcomingTournaments(
  Iterable<TournamentPreview> tournaments,
  DateTime now,
) {
  final oldestRelevantDate = now.subtract(const Duration(days: 2));
  final result = tournaments.where((tournament) {
    final lastEventDate = tournament.endDate ?? tournament.startDate;
    return lastEventDate != null && !lastEventDate.isBefore(oldestRelevantDate);
  }).toList()
    ..sort(_compareTournamentDates);
  return List.unmodifiable(result);
}

bool isTournamentActive(TournamentPreview tournament, DateTime now) {
  final start = tournament.startDate;
  final end = tournament.endDate;
  if (start == null || end == null) {
    return false;
  }

  // Compare calendar dates because API event timestamps commonly represent
  // midnight at the start of the first and last event dates.
  final today = DateTime.utc(now.year, now.month, now.day);
  final firstDay = DateTime.utc(start.year, start.month, start.day);
  final lastDay = DateTime.utc(end.year, end.month, end.day);
  return !today.isBefore(firstDay) && !today.isAfter(lastDay);
}

int _compareTournamentDates(TournamentPreview first, TournamentPreview second) {
  final firstDate = first.startDate;
  final secondDate = second.startDate;
  if (firstDate == null) return secondDate == null ? 0 : 1;
  if (secondDate == null) return -1;
  return firstDate.compareTo(secondDate);
}

Future<TournamentList> getTournaments(
    String eventName, ExploreSearchFilter filters,
    {bool getAllPages = false, int page = 1}) async {
  const apiPageSize = 250;
  const uiPageSize = 25;
  final seasonId =
      filters.gradeLevel.id == 4 ? filters.season.vexUId : filters.season.vrcId;

  final query = <String, String>{
    'season[]': seasonId.toString(),
    'start': _startOfUtcDate(filters.startDate).toIso8601String(),
    'end': _endOfUtcDate(filters.endDate).toIso8601String(),
    'myEvents': 'false',
    'per_page': apiPageSize.toString(),
  };

  final region = filters.location?.region?.trim();
  if (region != null && region.isNotEmpty) {
    query['region'] = region;
  }

  final level = _apiLevel(filters.levelClass.id);
  if (level != null) {
    query['level[]'] = level;
  }

  final firstResponse = await _fetchEventsPage(query, 1);
  final firstBody = jsonDecode(firstResponse.body) as Map<String, dynamic>;
  final lastApiPage = (firstBody['meta']['last_page'] as num).toInt();
  final allData = <dynamic>[...(firstBody['data'] as List)];

  if (lastApiPage > 1) {
    final remaining = await Future.wait([
      for (var apiPage = 2; apiPage <= lastApiPage; apiPage++)
        _fetchEventsPage(query, apiPage),
    ]);
    for (final response in remaining) {
      allData.addAll(jsonDecode(response.body)['data'] as List);
    }
  }

  final normalizedName = eventName.trim().toLowerCase();
  final tournaments = allData
      .cast<Map<String, dynamic>>()
      .where((event) =>
          normalizedName.isEmpty ||
          (event['name'] as String? ?? '')
              .toLowerCase()
              .contains(normalizedName) ||
          (event['sku'] as String? ?? '')
              .toLowerCase()
              .contains(normalizedName))
      .map(TournamentPreview.fromJson)
      .toList()
    ..sort(_compareTournamentDates);

  final maxPage =
      tournaments.isEmpty ? 1 : (tournaments.length / uiPageSize).ceil();
  if (getAllPages) {
    return TournamentList(tournaments: tournaments, maxPage: maxPage);
  }

  final safePage = page.clamp(1, maxPage).toInt();
  final start = (safePage - 1) * uiPageSize;
  final end = (start + uiPageSize).clamp(0, tournaments.length).toInt();
  return TournamentList(
    tournaments: tournaments.sublist(start, end),
    maxPage: maxPage,
  );
}

Future<http.Response> _fetchEventsPage(
    Map<String, String> query, int page) async {
  final response = await http.get(
    Uri.https('events.vex.com', '/api/v2/events', {
      ...query,
      'page': page.toString(),
    }),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
      HttpHeaders.acceptHeader: 'application/json',
    },
  ).timeout(const Duration(seconds: 12));
  if (response.statusCode != 200) {
    throw Exception(
      'VEX event search failed (${response.statusCode}): ${response.body}',
    );
  }
  return response;
}

String? _apiLevel(int levelClassId) {
  return switch (levelClassId) {
    1 => 'Regional',
    2 || 13 => 'National',
    3 => 'World',
    9 => 'Signature',
    12 => 'Regional',
    16 => 'Other',
    _ => null,
  };
}

DateTime _startOfUtcDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

DateTime _endOfUtcDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day, 23, 59, 59, 999);
