import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<Tournament> getTournamentDetails(int tournamentID) async {
  Tournament tournament;
  final response = await http.get(
    Uri.parse("https://www.robotevents.com/api/v2/events/$tournamentID"),
    headers: {
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body);
    tournament = Tournament(
        id: tournamentID,
        name: parsed["name"],
        seasonID: parsed["season"]["id"],
        location: Location(venue: parsed["location"]["venue"]),
        startDate: DateTime.parse(parsed["start"]),
        endDate: DateTime.parse(parsed["end"]),
        divisions: parsed["divisions"].map<Division>((division) {
          return Division(
              id: division["id"],
              name: division["name"],
              order: division["order"]);
        }).toList());
  } else {
    throw Exception("Failed to load tournament details");
  }

  return tournament;
}
