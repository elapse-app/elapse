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

class SearchPageData {
  List<TournamentPreview> tournaments;
  int maxPage;

  SearchPageData({required this.tournaments, required this.maxPage});
}

Future<List<TournamentPreview>> fetchTeamTournaments(
  int teamId,
  int seasonID,
) async {
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

Future<SearchPageData> getTournaments(EventSearchFilters filters,
    {int page = 1}) async {
  try {
    final parser = await Chaleno().load(
        "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=${filters.seasonID}&eventType=&name=${filters.eventName}&grade_level_id=${filters.gradeLevelID}&level_class_id=${filters.levelClassID}&from_date=${filters.startDate}&to_date=${filters.endDate}&event_region=&city=&distance=30&page=$page");

    List<Result> result = parser!.querySelectorAll(
        '#competitions-app > div.col-sm-8.results > div > div > div');

    List<Result> pages = parser.querySelectorAll(
        '#competitions-app > div.col-sm-8.results > nav > ul > li');
    int maxPage = pages.length - 2;
    if (maxPage < 1) {
      maxPage = 1;
    }
    List<Future<TournamentPreview?>> tournamentFutures = [];
    List<TournamentPreview> tournaments = [];
    for (var e in result) {
      tournamentFutures.add(itemParse(e.text));
    }

    await Future.wait(tournamentFutures).then((value) {
      tournaments = value
          .where((element) => element != null)
          .toList()
          .cast<TournamentPreview>();
    });

    return SearchPageData(tournaments: tournaments, maxPage: maxPage);
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
