import "dart:convert";

import "package:elapse_app/classes/Tournament/game.dart";
import 'package:elapse_app/classes/Tournament/tskills.dart';
import "package:elapse_app/extras/token.dart";

import "package:ml_linalg/matrix.dart";
import "package:http/http.dart" as http;
import "dart:io";

class TeamStats {
  int rank = 0;

  int wins = 0;
  int losses = 0;
  int ties = 0;
  int totalMatches = 0;

  int wp = 0;
  int ap = 0;
  int sp = 0;

  int awp = 0;
  double awpRate = 0;

  double opr = 0;
  double dpr = 0;
  double ccwm = 0;

  int highScore = 0;
  double avgScore = 0;
  int totalScore = 0;

  TournamentSkills? tournamentSkills;

  TeamStats();

  Map<String, dynamic> toJson() {
    return {
      "rank": rank,
      "wins": wins,
      "losses": losses,
      "ties": ties,
      "totalMatches": totalMatches,
      "wp": wp,
      "ap": ap,
      "sp": sp,
      "awp": awp,
      "awpRate": awpRate,
      "opr": opr,
      "dpr": dpr,
      "ccwm": ccwm,
      "highScore": highScore,
      "avgScore": avgScore,
      "totalScore": totalScore,
      "tournamentSkills": tournamentSkills?.toJson(),
    };
  }
}

TeamStats loadTeamStats(stats) {
  return TeamStats()
    ..rank = stats["rank"]
    ..wins = stats["wins"]
    ..losses = stats["losses"]
    ..ties = stats["ties"]
    ..wp = stats["wp"]
    ..ap = stats["ap"]
    ..sp = stats["sp"]
    ..awp = stats["awp"]
    ..awpRate = stats["awpRate"]
    ..opr = stats["opr"]
    ..dpr = stats["dpr"]
    ..ccwm = stats["ccwm"]
    ..highScore = stats["highScore"]
    ..avgScore = stats["avgScore"]
    ..totalScore = stats["totalScore"]
    ..tournamentSkills = stats["tournamentSkills"] != null
        ? loadSkills(stats["tournamentSkills"])
        : null;
}

Future<List<dynamic>> calcEventStats(int eventId, int divisionId) async {
  Map<int, TeamStats> stats = {};

  // Get qualifier matches
  List<Game> allMatches = [];
  List<Game> qualiMatches = [];
  Map<int, TournamentSkills> skills = {};
  var rankings;
  List parsedRankings = [];

  List<Future<void>> requestFutures = [];
  requestFutures.add(getTournamentSchedule(eventId, divisionId)!.then((m) {
    allMatches = m;
    qualiMatches = m.where((e) => e.roundNum == 2).toList();
  }));
  requestFutures.add(http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/rankings?per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
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
    TeamStats? stat = stats[teamId];
    if (stat == null) continue;

    stat.rank = t["rank"] ?? 0;

    stat.wins = t["wins"] ?? 0;
    stat.losses = t["losses"] ?? 0;
    stat.ties = t["ties"] ?? 0;
    stat.totalMatches = stat.wins + stat.losses + stat.ties;

    stat.wp = t["wp"];
    stat.ap = t["ap"];
    stat.sp = t["sp"];

    stat.awp = stat.wp - 2 * stat.wins;
    stat.awpRate = stat.awp / (stat.totalMatches == 0 ? 1 : stat.totalMatches);

    stat.highScore = t["high_score"] ?? 0;
    stat.avgScore = (t["average_points"] ?? 0).toDouble();
    stat.totalScore = t["total_points"] ?? 0;

    stats[teamId]?.tournamentSkills = skills[teamId];
  }

  List<Future<void>> pgFutures = [];
  int teamsLastPage = jsonDecode(rankings.body)["meta"]["last_page"];
  for (int pg = 2; pg <= teamsLastPage; pg++) {
    Future<void> pgResponse = http.get(
        Uri.parse(
            "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/rankings?page=$pg"),
        headers: {
          HttpHeaders.authorizationHeader: getToken(),
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

        stats[teamId]?.tournamentSkills = skills[teamId];
      }
    });
    pgFutures.add(pgResponse);
  }
  await Future.wait(pgFutures);

  // Process matches
  List<double> redScores = [];
  List<double> blueScores = [];

  int statsLength = stats.keys.length;

  List<Map<int, double>> redMatchTeams =
      List.generate(qualiMatches.length, (_) {
    return Map.fromIterables(stats.keys, List<double>.filled(statsLength, 0));
  });
  List<Map<int, double>> blueMatchTeams =
      List.generate(qualiMatches.length, (_) {
    return Map.fromIterables(stats.keys, List<double>.filled(statsLength, 0));
  });

  // Determine which teams played in each match and each match's scores
  for (int i = 0; i < qualiMatches.length; i++) {
    Game match = qualiMatches[i];

    redScores.add((match.redScore ?? 0).toDouble());
    blueScores.add((match.blueScore ?? 0).toDouble());

    if (redMatchTeams[i].containsKey(match.redAlliancePreview![0].teamID)) {
      redMatchTeams[i][match.redAlliancePreview![0].teamID] = 1;
    } else {
      print(
          "Match $i: Team ${match.redAlliancePreview?[0].teamNumber} is not in the rankings and therefore has not been included in calculations");
    }
    if (redMatchTeams[i].containsKey(match.redAlliancePreview![1].teamID)) {
      redMatchTeams[i][match.redAlliancePreview![1].teamID] = 1;
    } else {
      print(
          "Match $i: Team ${match.redAlliancePreview?[1].teamNumber} is not in the rankings and therefore has not been included in calculations");
    }
    if (blueMatchTeams[i].containsKey(match.blueAlliancePreview![0].teamID)) {
      blueMatchTeams[i][match.blueAlliancePreview![0].teamID] = 1;
    } else {
      print(
          "Match $i: Team ${match.blueAlliancePreview?[0].teamNumber} is not in the rankings and therefore has not been included in calculations");
    }
    if (blueMatchTeams[i].containsKey(match.blueAlliancePreview![1].teamID)) {
      blueMatchTeams[i][match.blueAlliancePreview![1].teamID] = 1;
    } else {
      print(
          "Match $i: Team ${match.blueAlliancePreview?[1].teamNumber} is not in the rankings and therefore has not been included in calculations");
    }
  }

  // Combine red and blue match teams
  List<List<double>> matchTeams =
      redMatchTeams.map((map) => map.values.toList()).toList() +
          blueMatchTeams.map((map) => map.values.toList()).toList();

  Matrix mScores = Matrix.column(redScores + blueScores);
  Matrix mOppScores = Matrix.column(blueScores + redScores);
  Matrix mMatches = Matrix.fromList(matchTeams);
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

  return [allMatches, stats];
}
