import "dart:convert";

import "package:elapse_app/classes/Tournament/game.dart";
import 'package:elapse_app/classes/Tournament/tskills.dart';
import "package:elapse_app/requests/schedule.dart";
import "package:elapse_app/requests/token.dart";

import "package:ml_linalg/matrix.dart";
import "package:http/http.dart" as http;
import "dart:io";

class TeamStats {
  int rank = 0;
  int wins = 0;
  int losses = 0;
  int ties = 0;

  int wp = 0;
  int ap = 0;
  int sp = 0;

  double opr = 0;
  double dpr = 0;
  double ccwm = 0;

  int highScore = 0;
  double avgScore = 0;
  int totalScore = 0;

  TournamentSkills? tournamentSkills;

  TeamStats();
}

Future<List<dynamic>> calcEventStats(int eventId, int divisionId) async {
  Map<int, TeamStats> stats = {};

  // Get qualifier matches
  List<Game> matches = [];
  var rankings;
  List parsedRankings = [];

  List<Future<void>> requestFutures = [];
  requestFutures.add(getTournamentSchedule(eventId, divisionId)!
      .then((m) => matches = m.where((e) => e.roundNum == 2).toList()));
  requestFutures.add(http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/rankings?per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  ).then((rankingsResponse) {
    rankings = rankingsResponse;

    if (rankingsResponse.statusCode != 200) {
      throw Exception("Failed to get rankings");
    }
    parsedRankings = jsonDecode(rankingsResponse.body)["data"] as List;
  }));
  await Future.wait(requestFutures);

  stats.addAll(Map<int, TeamStats>.fromEntries(
      parsedRankings.map((v) => MapEntry(v["team"]["id"], TeamStats()))));
  for (final t in parsedRankings) {
    int teamId = t["team"]["id"];

    stats[teamId]?.rank = t["rank"] ?? 0;

    stats[teamId]?.wins = t["wins"] ?? 0;
    stats[teamId]?.losses = t["losses"] ?? 0;
    stats[teamId]?.ties = t["ties"] ?? 0;

    stats[teamId]?.wp = t["wp"];
    stats[teamId]?.ap = t["ap"];
    stats[teamId]?.sp = t["sp"];

    stats[teamId]?.highScore = t["high_score"] ?? 0;
    stats[teamId]?.avgScore = (t["average_points"] ?? 0).toDouble();
    stats[teamId]?.totalScore = t["total_points"] ?? 0;
  }

  List<Future<void>> pgFutures = [];
  int teamsLastPage = jsonDecode(rankings.body)["meta"]["last_page"];
  for (int pg = 2; pg <= teamsLastPage; pg++) {
    print("getting additional rankings");
    Future<void> pgResponse = http.get(
        Uri.parse(
            "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/rankings?page=$pg"),
        headers: {
          HttpHeaders.authorizationHeader: TOKEN,
        }).then((pgResponse) {
      if (pgResponse.statusCode != 200) {
        throw Exception("Failed to get rankings page $pg");
      }
      final parsedPg = jsonDecode(pgResponse.body)["data"] as List;

      stats.addAll(Map<int, TeamStats>.fromEntries(
          parsedPg.map((v) => MapEntry(v["team"]["id"], TeamStats()))));
      for (final t in parsedPg) {
        int teamId = t["team"]["id"];

        stats[teamId]?.rank = t["rank"] ?? 0;

        stats[teamId]?.wins = t["wins"] ?? 0;
        stats[teamId]?.losses = t["losses"] ?? 0;
        stats[teamId]?.ties = t["ties"] ?? 0;

        stats[teamId]?.wp = t["wp"];
        stats[teamId]?.ap = t["ap"];
        stats[teamId]?.sp = t["sp"];

        stats[teamId]?.highScore = t["high_score"] ?? 0;
        stats[teamId]?.avgScore = (t["average_points"] ?? 0).toDouble();
        stats[teamId]?.totalScore = t["total_points"] ?? 0;
      }
    });
    pgFutures.add(pgResponse);
  }
  await Future.wait(pgFutures);

  // Process matches
  // Process matches
  List<double> redScores = [];
  List<double> blueScores = [];

  int statsLength = stats.keys.length;

  List<Map<int, double>> redMatchTeams = List.generate(matches.length, (_) {
    return Map.fromIterables(stats.keys, List<double>.filled(statsLength, 0));
  });
  List<Map<int, double>> blueMatchTeams = List.generate(matches.length, (_) {
    return Map.fromIterables(stats.keys, List<double>.filled(statsLength, 0));
  });

// Determine which teams played in each match and each match's scores
  for (int i = 0; i < matches.length; i++) {
    Game match = matches[i];

    redScores.add((match.redScore ?? 0).toDouble());
    blueScores.add((match.blueScore ?? 0).toDouble());

    redMatchTeams[i][match.redAlliancePreview![0].teamID] = 1;
    redMatchTeams[i][match.redAlliancePreview![1].teamID] = 1;
    blueMatchTeams[i][match.blueAlliancePreview![0].teamID] = 1;
    blueMatchTeams[i][match.blueAlliancePreview![1].teamID] = 1;
  }

// Combine red and blue match teams
  List<List<double>> matchTeams =
      redMatchTeams.map((map) => map.values.toList()).toList() +
          blueMatchTeams.map((map) => map.values.toList()).toList();

// Debugging: Print lengths of each nested list
  for (int i = 0; i < matchTeams.length; i++) {
    print("Length of matchTeams[$i]: ${matchTeams[i].length}");
  }

// Ensure all nested lists have the expected length
  int expectedLength = stats.keys.length;
  for (int i = 0; i < matchTeams.length; i++) {
    if (matchTeams[i].length != expectedLength) {
      throw Exception(
          "Wrong nested list length: ${matchTeams[i].length}, expected length: $expectedLength at index $i");
    }
  }

  Matrix mScores = Matrix.column(redScores + blueScores);
  Matrix mOppScores = Matrix.column(blueScores + redScores);
  Matrix mMatches =
      Matrix.fromList(matchTeams); // This is where the error occurs
  Matrix mMatchesT = mMatches.transpose();

  Matrix mOPR = (mMatchesT * mMatches).solve(mMatchesT * mScores);
  Matrix mDPR = (mMatchesT * mMatches).solve(mMatchesT * mOppScores);
  List<double> opr = mOPR.toList().expand((i) => i).toList();
  List<double> dpr = mDPR.toList().expand((i) => i).toList();

  int i = 0;
  for (var stat in stats.values) {
    stat.opr = double.parse(opr[i].toStringAsFixed(2));
    stat.dpr = double.parse(dpr[i].toStringAsFixed(2));
    stat.ccwm = double.parse((stat.opr - stat.dpr).toStringAsFixed(2));
    i++;
  }

  return [matches, stats];
}
