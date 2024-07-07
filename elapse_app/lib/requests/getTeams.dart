import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/requests/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<List<Team>> getTeams(int tournamentID) async {
  List<Team> teams = [];
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$tournamentID/teams?per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"];
    teams = parsed.map<Team>((json) => Team.fromJson(json)).toList();
    // print("finished getting teams");
  } else {
    throw Exception("Failed to load teams");
  }
  int lastPage = jsonDecode(response.body)["meta"]["last_page"];
  if (lastPage > 1) {
    // Fetch remaining pages in parallel
    List<Future<void>> pageFutures = [];
    for (int page = 2; page <= lastPage; page++) {
      pageFutures.add(_fetchAdditionalTeams(tournamentID, page, teams));
    }
    await Future.wait(pageFutures);
  }
  return teams;
}

Future<void> _fetchAdditionalTeams(
    int tournamentID, int page, List<Team> teams) async {
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$tournamentID/teams?page=$page&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    teams.addAll(parsed.map<Team>((json) => Team.fromJson(json)).toList());
  } else {
    throw Exception("Failed to load schedule");
  }
}
