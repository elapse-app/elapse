import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;

import '../../screens/explore/filters.dart';

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
    Map<String, dynamic> locationJson = json['location'];
    Location location = new Location(
        address1: locationJson['address_1'],
        address2: locationJson['address_2'],
        city: locationJson['city'],
        region: locationJson['region'],
        country: locationJson['country'],
        venue: locationJson['venue']);
    return TournamentPreview(
      id: json['id'],
      name: json['name'],
      location: location,
      startDate: DateTime.parse(json['start']),
      endDate: DateTime.parse(json['end']),
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
  List<TournamentPreview> tournaments;
  int maxPage;

  TournamentList({required this.tournaments, required this.maxPage});
}

Future<List<TournamentPreview>> fetchTeamTournaments(
  int teamId,
  int seasonID,
) async {
  // Fetch team data

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
  List<TournamentPreview> tournaments = parsedTournamentInfo
      .map<TournamentPreview>((json) => TournamentPreview.fromJson(json))
      .toList();

  return tournaments;
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
          (event['name'] as String).toLowerCase().contains(normalizedName) ||
          (event['sku'] as String).toLowerCase().contains(normalizedName))
      .map(TournamentPreview.fromJson)
      .toList()
    ..sort((a, b) => a.startDate!.compareTo(b.startDate!));

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
  );
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
