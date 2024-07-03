import 'dart:convert';

import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
// import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:chaleno/chaleno.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/requests/token.dart';
import 'package:http/http.dart' as http;

import 'dart:core';

import 'dart:io';

Future<List<TournamentPreview?>> getTournaments(
    EventSearchFilters filters) async {
  try {
    print("Loading ");
    final parser = await Chaleno().load(
        // "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=&eventType=&name${filters.eventName}=&grade_level_id=${filters.gradeLevelID}&level_class_id=${filters.levelClassID}&from_date=${filters.startDate}&to_date=${filters.endDate}&event_region=${filters.endDate}&city=&distance=30");
        "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=&eventType=&name=&grade_level_id=&level_class_id=&from_date=2024-06-11&to_date=&event_region=2504&city=&distance=30");

    print("Loaded");

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
