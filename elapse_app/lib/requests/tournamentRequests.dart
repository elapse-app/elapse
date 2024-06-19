import 'dart:convert';

import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
// import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:chaleno/chaleno.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
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
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
    },
  );

  final parsed = jsonDecode(response.body)["data"] as List;
  TournamentPreview tournamentPreview = parsed
      .map<TournamentPreview>((json) => TournamentPreview.fromJson(json))
      .toList()[0];

  return tournamentPreview;
}
