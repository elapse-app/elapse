import 'package:elapse_app/classes/Team/team.dart';

import "dart:convert";
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import "dart:io";

class TournamentSkills {
  int rank = 0;
  int score = 0;

  int autonScore = 0;
  int autonAttempts = 0;

  int driverScore = 0;
  int driverAttempts = 0;

  TournamentSkills();

  Map<String, dynamic> toJson() {
    return {
      "rank": rank,
      "score": score,
      "autonScore": autonScore,
      "autonAttempts": autonAttempts,
      "driverScore": driverScore,
      "driverAttempts": driverAttempts,
    };
  }
}

TournamentSkills loadSkills(skills) {
  return TournamentSkills()
    ..rank = skills["rank"]
    ..score = skills["score"]
    ..autonScore = skills["autonScore"]
    ..autonAttempts = skills["autonAttempts"]
    ..driverScore = skills["driverScore"]
    ..driverAttempts = skills["driverAttempts"];
}

Future<Map<int, TournamentSkills>> getSkillsRankings(
    int eventId, Future<List<Team>> futureTeams) async {
  Map<int, TournamentSkills> rankings = {};

  List<Team> teams = [];
  int skillsLastPage = 1;
  List parsedSkills = [];

  List<Future<void>> requestFutures = [];
  requestFutures.add(futureTeams.then((t) {
    teams = t;
  }));
  requestFutures.add(http
      .get(
        Uri.parse(
            "https://events.vex.com/api/v2/events/$eventId/skills?per_page=250"),
        headers: {
          HttpHeaders.authorizationHeader: getToken(),
        },
      )
      .timeout(const Duration(seconds: 12))
      .then((s) {
        if (s.statusCode != 200) {
          throw Exception("Failed to get rankings");
        }
        final decoded = jsonDecode(s.body);
        parsedSkills = decoded["data"] as List;
        skillsLastPage = (decoded["meta"]["last_page"] as num).toInt();
      }));
  await Future.wait(requestFutures);

  rankings.addAll(Map<int, TournamentSkills>.fromEntries(
    teams.map(
      (v) => MapEntry(v.id, TournamentSkills()),
    ),
  ));
  for (final t in parsedSkills) {
    int teamId = t["team"]["id"];

    rankings[teamId]?.rank = t["rank"];
    if (t["type"] == "programming") {
      rankings[teamId]?.autonScore = t["score"];
      rankings[teamId]?.autonAttempts = t["attempts"];
    } else {
      rankings[teamId]?.driverScore = t["score"];
      rankings[teamId]?.driverAttempts = t["attempts"];
    }
    rankings[teamId]?.score =
        rankings[teamId]!.autonScore + rankings[teamId]!.driverScore;
  }
  List<Future<void>> pgFutures = [];
  for (int pg = 2; pg <= skillsLastPage; pg++) {
    Future<void> pgResponse = http.get(
        Uri.parse(
            "https://events.vex.com/api/v2/events/$eventId/skills?page=$pg&per_page=250"),
        headers: {
          HttpHeaders.authorizationHeader: getToken(),
        }).then((pgResponse) {
      if (pgResponse.statusCode != 200) {
        throw Exception("Failed to get skills page $pg");
      }
      final parsedPg = jsonDecode(pgResponse.body)["data"] as List;

      for (final t in parsedPg) {
        int teamId = t["team"]["id"];

        rankings[teamId]?.rank = t["rank"];
        if (t["type"] == "programming") {
          rankings[teamId]?.autonScore = t["score"];
          rankings[teamId]?.autonAttempts = t["attempts"];
        } else {
          rankings[teamId]?.driverScore = t["score"];
          rankings[teamId]?.driverAttempts = t["attempts"];
        }
        rankings[teamId]?.score =
            rankings[teamId]!.autonScore + rankings[teamId]!.driverScore;
      }
    });
    pgFutures.add(pgResponse);
  }
  await Future.wait(pgFutures);

  return rankings;
}
