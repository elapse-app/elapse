import "dart:convert";

import "package:elapse_app/classes/Tournament/game.dart";
import "package:elapse_app/requests/teamLookup.dart";
import "package:elapse_app/classes/Team/team.dart";

import "package:ml_linalg/matrix.dart";
import "package:http/http.dart" as http;
import "dart:io";

class TeamStats {
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
  int avgScore = 0;
  int ttlScore = 0;
}

class EventTeamStats {
  Map<Team, TeamStats> stats = {};

  EventTeamStats();

  static Future<EventTeamStats> calculate(int eventId, int divisionId) async {
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
    final parsedRankings = jsonDecode(rankings.body) as List;

    // Matches data from robotevents
    final matches = await http.get(
      Uri.parse("https://www.robotevents.com/api/v2/events/$eventId/divions/$divisionId/matches?round%5B%5D=2"),
      headers: {
        HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
      },
    );
    if (matches.statusCode != 200) {
      throw Exception("Failed to get matches");
    }
    final parsedMatches = jsonDecode(matches.body) as List;


    EventTeamStats teamStats = EventTeamStats();
    Map<Team, TeamStats> stats = teamStats.stats;

    // Process Robotevents stats
    for (final t in parsedRankings) {
      Team team = await fetchTeam(t["team"]["id"]);
      
      stats.putIfAbsent(team, () => TeamStats());

      stats[team]?.wins = t["wins"];
      stats[team]?.losses = t["losses"];
      stats[team]?.ties = t["ties"];

      stats[team]?.wp = t["wp"];
      stats[team]?.ap = t["ap"];
      stats[team]?.sp = t["sp"];

      stats[team]?.highScore = t["high_score"];
      stats[team]?.avgScore = t["average_score"];
      stats[team]?.ttlScore = t["total_score"];
    }

    // Process matches
    List<double> redScores = [];
    List<double> blueScores = [];
    List<Map<Team, double>> redMatchTeams = List.generate(parsedMatches.length, (_) {
      return Map.fromIterables(stats.keys, List<double>.filled(stats.keys.length, 0.0));
    });
    List<Map<Team, double>> blueMatchTeams = List.generate(parsedMatches.length, (_) {
      return Map.fromIterables(stats.keys, List<double>.filled(stats.keys.length, 0.0));
    });

    // Determine which teams played in each match and each match's scores
    for (int i = 0; i < parsedMatches.length; i++) {
      Game match = parsedMatches[i];

      redScores.add((match.redScore ?? 0).toDouble());
      blueScores.add((match.blueScore ?? 0).toDouble());

      redMatchTeams[i][await fetchTeam(match.redAllianceID![0])] = 1.0;
      redMatchTeams[i][await fetchTeam(match.redAllianceID![1])] = 1.0;
      blueMatchTeams[i][await fetchTeam(match.blueAllianceID![0])] = 1.0;
      blueMatchTeams[i][await fetchTeam(match.blueAllianceID![1])] = 1.0;
    }

    // OPR and DPR calculations
    List<double> scores = redScores + blueScores;
    List<double> oppScores = blueScores + redScores;
    List<List<double>> matchTeams = redMatchTeams.map((map) => map.values.toList()).toList() + blueMatchTeams.map((map) => map.values.toList()).toList();
    
    Matrix mScores = Matrix.column(scores + oppScores);
    Matrix mOppScores = Matrix.column(oppScores + scores);
    Matrix mMatches = Matrix.fromList(matchTeams);
    Matrix mMatchesT = mMatches.transpose();

    Matrix mOPR = (mMatchesT * mMatches).solve(mMatchesT * mScores);
    Matrix mDPR = (mMatchesT * mMatches).solve(mMatchesT * mOppScores);
    List<double> opr = mOPR.toList().expand((i) => i).toList();
    List<double> dpr = mDPR.toList().expand((i) => i).toList();

    int i = 0;
    for (var stat in stats.values) {
      stat.opr = opr[i];
      stat.dpr = dpr[i];
      stat.ccwm = stat.opr - stat.dpr;
      i++;
    }

    return teamStats;
  }
}