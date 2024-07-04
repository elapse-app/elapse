import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/requests/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<List<Team>> getTeams(int tournamentID, int divisionID) async {
  List<Team> teams = [];
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$tournamentID/divisions/$divisionID/rankings?per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"];
    teams = parsed.map<Team>((json) => Team.fromJson(json)).toList();
    // print("finished getting teams");
    return teams;
  } else {
    throw Exception("Failed to load teams");
  }
}
