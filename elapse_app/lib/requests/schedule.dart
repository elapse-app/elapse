import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:http/http.dart' as http;

Future<List<Game>>? getQualifierMatches(int tournamentID, int divisionID) async {
  List<Game>? schedule = await getTournamentSchedule(tournamentID, divisionID);

  List<Game>? qualifiers = [];
  for (int i = 0; i < schedule!.length; i++) {
    if (schedule[i].roundNum == 2) {
      qualifiers.add(schedule[i]);
    }
  }
  return qualifiers;
}

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
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    divisionMatches = parsed.map<Game>((json) => Game.fromJson(json)).toList();
  } else {
    print(response.body);
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
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    divisionMatches
        .addAll(parsed.map<Game>((json) => Game.fromJson(json)).toList());
  } else {
    print(response.body);
    throw Exception("Failed to load schedule");
  }
}
