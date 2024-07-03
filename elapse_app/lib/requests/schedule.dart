import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/requests/token.dart';
import 'package:http/http.dart' as http;

Future<List<Game>>? getTournamentSchedule(
    int tournamentID, int divisionID) async {
  // Fetch data for each division in parallel
  final divisionMatches = await _fetchDivisionMatches(tournamentID, divisionID);

  // Sort and print the matches

  divisionMatches.sort((a, b) {
    int result = a.roundNum.compareTo(b.roundNum);
    if (result != 0) return result;

    result = a.gameNum.compareTo(b.gameNum);
    if (result != 0) return result;

    return a.instance.compareTo(b.instance);
  });

  return divisionMatches;
}

Future<List<Game>> _fetchDivisionMatches(int eventId, divisionID) async {
  List<Game> divisionMatches = [];
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionID/matches"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    divisionMatches = parsed.map<Game>((json) => Game.fromJson(json)).toList();
  } else {
    print("status code was not 200");
    throw Exception("Failed to load schedule");
  }

  int lastPage = jsonDecode(response.body)["meta"]["last_page"];
  if (lastPage > 1) {
    // Fetch remaining pages in parallel
    List<Future<void>> pageFutures = [];
    for (int page = 2; page <= lastPage; page++) {
      pageFutures.add(
          _fetchAdditionalPage(eventId, divisionID, page, divisionMatches));
    }
    await Future.wait(pageFutures);
  }

  return divisionMatches;
}

Future<void> _fetchAdditionalPage(
    int eventId, int divisionId, int page, List<Game> divisionMatches) async {
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/matches?page=$page"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    divisionMatches
        .addAll(parsed.map<Game>((json) => Game.fromJson(json)).toList());
  } else {
    print("status code was not 200");
    print(response.body);
    throw Exception("Failed to load schedule");
  }
}
