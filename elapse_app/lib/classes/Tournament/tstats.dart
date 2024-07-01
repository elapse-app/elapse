import "dart:convert";

import "package:elapse_app/classes/Tournament/game.dart";
import 'package:elapse_app/classes/Tournament/tskills.dart';
import "package:elapse_app/requests/schedule.dart";

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

class TournamentStats {
  Map<int, TeamStats> stats = {};

  TournamentStats();

  static Future<TournamentStats> calculate(int eventId, int divisionId) async {
    TournamentStats teamStats = TournamentStats();
    Map<int, TeamStats> stats = teamStats.stats;

    // Get qualifier matches
    List<Game>? matches = (await getTournamentSchedule(eventId, divisionId))?.where((f) => f.roundNum == 2).toList();

    // Rankings data from robotevents
    final rankings = await http.get(
      Uri.parse("https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/rankings"),
      headers: {
        HttpHeaders.authorizationHeader:
        "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
      },
    );
    if (rankings.statusCode != 200) {
      throw Exception("Failed to get rankings");
    }
    final parsedRankings = jsonDecode(rankings.body)["data"] as List;
    stats.addAll(Map<int, TeamStats>.fromEntries(parsedRankings.map((v) => MapEntry(v["team"]["id"], TeamStats()))));
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
      stats[teamId]?.avgScore = (t["average_points"] ?? 0.0).toDouble();
      stats[teamId]?.totalScore = t["total_points"] ?? 0;
    }

    int teamsLastPage = jsonDecode(rankings.body)["meta"]["last_page"];
    List<Future<void>> pgFutures = [];
    for (int pg = 2; pg <= teamsLastPage; pg++) {
      Future<void> pgResponse = http.get(
        Uri.parse("https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/rankings?page=$pg"),
        headers: {
          HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
        }).then((pgResponse) {
          if (pgResponse.statusCode != 200) {
            throw Exception("Failed to get rankings page $pg");
          }
          final parsedPg = jsonDecode(pgResponse.body)["data"] as List;

          stats.addAll(Map<int, TeamStats>.fromEntries(
              parsedPg.map((v) => MapEntry(v["team"]["id"], TeamStats()))));
          for (final t in parsedPg) {
            int teamId = t["team"]["id"];

            stats[teamId]?.wins = t["wins"] ?? 0;
            stats[teamId]?.losses = t["losses"] ?? 0;
            stats[teamId]?.ties = t["ties"] ?? 0;

            stats[teamId]?.wp = t["wp"];
            stats[teamId]?.ap = t["ap"];
            stats[teamId]?.sp = t["sp"];

            stats[teamId]?.highScore = t["high_score"] ?? 0;
            stats[teamId]?.avgScore = (t["average_points"] ?? 0.0).toDouble();
            stats[teamId]?.totalScore = t["total_points"] ?? 0;
          }
        });
      pgFutures.add(pgResponse);
    }
    await Future.wait(pgFutures);

    // Process matches
    List<double> redScores = [];
    List<double> blueScores = [];

    List<Map<int, double>> redMatchTeams = List.generate(matches!.length, (_) {
      return Map.fromIterables(stats.keys, List<double>.filled(stats.keys.length, 0.0));
    });
    List<Map<int, double>> blueMatchTeams = List.generate(matches.length, (_) {
      return Map.fromIterables(stats.keys, List<double>.filled(stats.keys.length, 0.0));
    });

    // Determine which teams played in each match and each match's scores
    for (int i = 0; i < matches.length; i++) {
      Game match = matches[i];

      redScores.add((match.redScore ?? 0).toDouble());
      blueScores.add((match.blueScore ?? 0).toDouble());

      redMatchTeams[i][match.redAllianceID![0]] = 1.0;
      redMatchTeams[i][match.redAllianceID![1]] = 1.0;
      blueMatchTeams[i][match.blueAllianceID![0]] = 1.0;
      blueMatchTeams[i][match.blueAllianceID![1]] = 1.0;
    }

    // OPR and DPR calculations
    List<double> scores = redScores + blueScores;
    List<double> oppScores = blueScores + redScores;
    List<List<double>> matchTeams = redMatchTeams.map((map) => map.values.toList()).toList() +
        blueMatchTeams.map((map) => map.values.toList()).toList();

    Matrix mScores = Matrix.column(scores);
    Matrix mOppScores = Matrix.column(oppScores);
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

    return teamStats;
  }
}