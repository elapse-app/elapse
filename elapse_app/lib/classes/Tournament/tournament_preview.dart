import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;

import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
import 'package:chaleno/chaleno.dart';
import 'package:intl/intl.dart';

import 'dart:core';

import '../../main.dart';
import '../../screens/explore/filters.dart';
import '../Team/teamPreview.dart';

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

  final tournamentInfo = http.get(
    Uri.parse("https://www.robotevents.com/api/v2/teams/$teamId/events?season%5B%5D=$seasonID&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  final loadedTournamentInfo = await tournamentInfo;
  final parsedTournamentInfo = jsonDecode(loadedTournamentInfo.body)["data"] as List;
  List<TournamentPreview> tournaments =
      parsedTournamentInfo.map<TournamentPreview>((json) => TournamentPreview.fromJson(json)).toList();

  return tournaments;
}

Future<TournamentList> getTournaments(String eventName, ExploreSearchFilter filters,
    {bool getAllPages = false, int page = 1}) async {
  try {
    dynamic parser, regions;
    List<Future<dynamic>> futures = [];
    futures.add(Chaleno().load(
        "https://www.robotevents.com/robot-competitions/${filters.gradeLevel.id == 4 ? "college-competition" : "vex-robotics-competition"}?country_id=*&seasonId=${filters.gradeLevel.id == 4 ? filters.season.vexUId ?? "" : filters.season.vrcId}&eventType=&name=$eventName&grade_level_id=${filters.gradeLevel.id != 0 ? filters.gradeLevel.id : ""}&level_class_id=${filters.levelClass.id == 0 ? "" : filters.levelClass.id}&from_date=${DateFormat("yyyy-MM-dd").format(filters.startDate)}&to_date=${DateFormat("yyyy-MM-dd").format(filters.endDate)}&event_region=&city=${filters.location != null ? filters.location!.city : ""}&distance=250&page=$page"));
    if (filters.location != null) {
      futures.add(http.get(
        Uri.parse(
            "https://www.robotevents.com/api/v2/events?season%5B%5D=${filters.gradeLevel.id == 4 ? filters.season.vexUId ?? "" : filters.season.vrcId}&start=${DateFormat("yyyy-MM-dd").format(filters.startDate)}&end=${DateFormat("yyyy-MM-dd").format(filters.endDate)}&region=${filters.location?.region ?? ""}&myEvents=false"),
        headers: {
          HttpHeaders.authorizationHeader: getToken(),
        },
      ));
    }
    await Future.wait(futures).then((v) {
      parser = v[0];
      if (v.length > 1) regions = v[1];
    });

    List<Result> result = parser!.querySelectorAll('#competitions-app > div.col-sm-8.results > div > div > div');

    List<Result> pages = parser.querySelectorAll('#competitions-app > div.col-sm-8.results > nav > ul > li');
    int maxPage = pages.length - 2;
    if (maxPage < 1) {
      maxPage = 1;
    }

    if (getAllPages && maxPage > 1) {
      List<Future<dynamic>> pages = [];
      for (int pg = 1; pg <= maxPage; pg++) {
        if (pg == page) continue;

        pages.add(Chaleno().load(
            "https://www.robotevents.com/robot-competitions/${filters.gradeLevel.id == 4 ? "college-competition" : "vex-robotics-competition"}?country_id=*&seasonId=${filters.gradeLevel.id == 4 ? filters.season.vexUId ?? "" : filters.season.vrcId}&eventType=&name=$eventName&grade_level_id=${filters.gradeLevel.id != 0 ? filters.gradeLevel.id : ""}&level_class_id=${filters.levelClass.id == 0 ? "" : filters.levelClass.id}&from_date=${DateFormat("yyyy-MM-dd").format(filters.startDate)}&to_date=${DateFormat("yyyy-MM-dd").format(filters.endDate)}&event_region=&city=${filters.location != null ? filters.location!.city : ""}&distance=250&page=$pg"));
      }
      await Future.wait(pages).then((v) {
        for (final p in v) {
          List<Result> results = p!.querySelectorAll('#competitions-app > div.col-sm-8.results > div > div > div');
          result.addAll(results);
        }
      });
    }

    List<TournamentPreview> regionTournaments = [];
    if (filters.location != null) {
      final parsedRegions = jsonDecode(regions.body)["data"] as List;
      regionTournaments = parsedRegions.map((e) => TournamentPreview.fromJson(e)).toList();
    }

    List<Future<TournamentPreview?>> tournamentFutures = [];
    List<TournamentPreview> tournaments = [];
    for (var e in result) {
      tournamentFutures.add(itemParse(e.text));
    }

    await Future.wait(tournamentFutures).then((value) {
      tournaments = value
          .where((element) => element != null && (regionTournaments.isEmpty || regionTournaments.contains(element)))
          .where((e) => e != null)
          .toList()
          .cast<TournamentPreview>();
    });

    return TournamentList(tournaments: tournaments, maxPage: maxPage);
  } catch (e) {
    throw e;
  }
}

Future<TournamentPreview?> itemParse(String? item) async {
  if (item == null) {
    print("returning null");
    return null;
  }
  print(item);
  String scrapedData = item;

  // Regular expressions to match the desired data
  RegExp codeRegExp = RegExp(r"Event Code:\s+([\w-]+)");
  Match? codeMatch = codeRegExp.firstMatch(scrapedData);
  String eventCode = codeMatch?.group(1) ?? "";

  final response = await http.get(
    Uri.parse("https://www.robotevents.com/api/v2/events?sku%5B%5D=$eventCode&myEvents=false"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  final parsed = jsonDecode(response.body)["data"] as List;
  TournamentPreview tournamentPreview =
      parsed.map<TournamentPreview>((json) => TournamentPreview.fromJson(json)).toList()[0];

  return tournamentPreview;
}
