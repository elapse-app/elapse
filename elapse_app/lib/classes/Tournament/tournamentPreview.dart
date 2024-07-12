import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;

import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
import 'package:chaleno/chaleno.dart';

import 'dart:core';

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
}

Future<List<TournamentPreview>> fetchTeamTournaments(
    int teamId, int seasonID) async {
  // Fetch team data

  final tournamentInfo = http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/teams/$teamId/events?season%5B%5D=$seasonID&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  final loadedTournamentInfo = await tournamentInfo;
  final parsedTournamentInfo =
      jsonDecode(loadedTournamentInfo.body)["data"] as List;
  List<TournamentPreview> tournaments = parsedTournamentInfo
      .map<TournamentPreview>((json) => TournamentPreview.fromJson(json))
      .toList();

  return tournaments;
}

Future<List<TournamentPreview?>> getTournaments(
    EventSearchFilters filters) async {
  try {
    final parser = await Chaleno().load(
        // "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=&eventType=&name${filters.eventName}=&grade_level_id=${filters.gradeLevelID}&level_class_id=${filters.levelClassID}&from_date=${filters.startDate}&to_date=${filters.endDate}&event_region=${filters.endDate}&city=&distance=30");
        "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=&eventType=&name=&grade_level_id=&level_class_id=&from_date=2024-06-11&to_date=&event_region=2504&city=&distance=30");

    List<Result> result = parser!.querySelectorAll(
        '#competitions-app > div.col-sm-8.results > div > div > div');

    Future<List<TournamentPreview?>> tournaments =
        Future.wait(result.map((e) async {
      return itemParse(e.text);
    }));

    return tournaments;
  } catch (e) {
    throw e;
  }
}

Future<TournamentPreview?> itemParse(String? item) async {
  if (item == null) {
    return null;
  }
  String scrapedData = item;

  // Regular expressions to match the desired data
  RegExp codeRegExp = RegExp(r"Event Code:\s+([\w-]+)");
  Match? codeMatch = codeRegExp.firstMatch(scrapedData);
  String eventCode = codeMatch?.group(1) ?? "";

  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events?sku%5B%5D=$eventCode&myEvents=false"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  final parsed = jsonDecode(response.body)["data"] as List;
  TournamentPreview tournamentPreview = parsed
      .map<TournamentPreview>((json) => TournamentPreview.fromJson(json))
      .toList()[0];

  return tournamentPreview;
}
