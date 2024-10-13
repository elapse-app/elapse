import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/main.dart';
import 'package:http/http.dart' as http;

import '../Filters/gradeLevel.dart';
import '../Filters/season.dart';

class VDAStats {
  int id;
  String teamNum;
  String? teamName;
  GradeLevel? gradeLevel;

  double? opr;
  double? dpr;
  double? ccwm;

  num? wins;
  num? losses;
  num? ties;
  num? matches;
  double? winPercent;

  double? trueSkill;
  num? trueSkillGlobalRank;
  num? trueSkillRegionRank;

  num? regionalQual;
  num? worldsQual;

  String? eventRegion;
  Location? location;

  num? skillsScore;
  num? maxAuto;
  num? maxDriver;

  num? worldSkillsRank;
  num? regionSkillsRank;

  VDAStats({
    required this.id,
    required this.teamNum,
    required this.teamName,
    required this.gradeLevel,
    required this.opr,
    required this.dpr,
    required this.ccwm,
    required this.wins,
    required this.losses,
    required this.ties,
    required this.matches,
    required this.winPercent,
    required this.trueSkill,
    required this.trueSkillGlobalRank,
    required this.trueSkillRegionRank,
    required this.regionalQual,
    required this.worldsQual,
    required this.eventRegion,
    this.location,
    this.skillsScore,
    this.maxAuto,
    this.maxDriver,
    this.worldSkillsRank,
    this.regionSkillsRank,
  });

  factory VDAStats.fromJson(Map<String, dynamic> json) {
    return VDAStats(
      id: json["id"].truncate(),
      teamNum: json["team_number"],
      teamName: json["team_name"],
      gradeLevel: gradeLevels[json["grade"]],
      opr: json["opr"],
      dpr: json["dpr"],
      ccwm: json["ccwm"],
      wins: json["total_wins"]?.truncate(),
      losses: json["total_losses"]?.truncate(),
      ties: json["total_ties"]?.truncate(),
      matches: json["total_matches"]?.truncate(),
      winPercent: double.tryParse(json["total_winning_percent"]?.toStringAsFixed(2) ?? ""),
      trueSkill: json["trueskill"],
      trueSkillGlobalRank: json["ts_ranking"],
      trueSkillRegionRank: json["ts_ranking_region"],
      regionalQual: json["qualified_for_regionals"],
      worldsQual: json["qualified_for_worlds"],
      eventRegion: json["event_region"] == "British Columbia" ? "British Columbia (BC)" : json["event_region"],
      location: Location(
        region: json["loc_region"],
        country: json["loc_country"],
      ),
      skillsScore: json["score_total_max"]?.truncate(),
      maxAuto: json["score_auto_max"]?.truncate(),
      maxDriver: json["score_driver_max"]?.truncate(),
      worldSkillsRank: json["total_skills_ranking"]?.truncate(),
      regionSkillsRank: json["region_grade_skills_rank"]?.truncate(),
    );
  }

  factory VDAStats.fromHistorical(Map<String, dynamic> json) {
    return VDAStats(
      id: json["team_id"]?.truncate() ?? 0,
      teamNum: json["team_num"] ?? "",
      teamName: json["team_name"],
      gradeLevel: null,
      opr: json["opr"],
      dpr: json["dpr"],
      ccwm: json["ccwm"],
      wins: (json["total_wins"] + json["elimination_wins"])?.truncate(),
      losses: (json["total_losses"] + json["elimination_losses"])?.truncate(),
      ties: (json["total_ties"] + json["elimination_losses"])?.truncate(),
      matches: (((json["total_wins"] + json["elimination_wins"]) ?? 0) +
                  ((json["total_losses"] + json["elimination_losses"]) ?? 0) +
                  ((json["total_ties"] + json["elimination_losses"]) ?? 0))
              ?.truncate() ??
          0,
      winPercent: double.parse((((json["total_wins"] + json["elimination_wins"]) ?? 0) /
              ((((json["total_wins"] + json["elimination_wins"]) ?? 0) +
                          ((json["total_losses"] + json["elimination_losses"]) ?? 0) +
                          ((json["total_ties"] + json["elimination_losses"]) ?? 0)) ==
                      0
                  ? 1
                  : (((json["total_wins"] + json["elimination_wins"]) ?? 0) +
                      ((json["total_losses"] + json["elimination_losses"]) ?? 0) +
                      ((json["total_ties"] + json["elimination_losses"]) ?? 0))) *
              100)
          .toStringAsFixed(2)),
      trueSkill: json["trueskill"],
      trueSkillGlobalRank: json["ts_ranking"]?.truncate(),
      trueSkillRegionRank: 0,
      regionalQual: 0,
      worldsQual: 0,
      eventRegion: "",
    );
  }
}

Future<List<VDAStats>> getTrueSkillData(int seasonId) async {
  final String? vdaData = prefs.getString("vdaData");

  List<dynamic> parsed = [];

  if (seasonId < 154) {
    // TiP season ID (earliest season that had VDA stats)
    return List<VDAStats>.empty();
  }

  if (seasonId != seasons[0].vrcId) {
    final response = await http.get(
      Uri.parse("https://vrc-data-analysis.com/v1/historical_allteams/$seasonId"),
    );
    parsed = jsonDecode(response.body) as List;

    List<VDAStats> vdaStats = parsed.map<VDAStats>((json) => VDAStats.fromHistorical(json)).toList();
    return vdaStats;
  } else if (!hasCachedTrueSkillData()) {
    final response = await http.get(
      Uri.parse("https://vrc-data-analysis.com/v1/allteams"),
    );

    parsed = jsonDecode(response.body) as List;
    prefs.setString("vdaData", response.body);
    prefs.setString("vdaExpiry", DateTime.now().add(const Duration(hours: 2)).toString());
  } else {
    parsed = jsonDecode(vdaData!) as List;
  }

  List<VDAStats> vdaStats = parsed.map<VDAStats>((json) => VDAStats.fromJson(json)).toList();
  return vdaStats;
}

Future<VDAStats?> getTrueSkillDataForTeam(int seasonId, String teamNum) async {
  final response = await getTrueSkillData(seasonId);
  if (response.isEmpty) return null;
  return response.firstWhere((element) => element.teamName == teamNum || element.teamNum == teamNum);
}

bool hasCachedTrueSkillData() {
  final String? vdaData = prefs.getString("vdaData");
  final String? expiryDate = prefs.getString("vdaExpiry");

  return vdaData != null && expiryDate != null && DateTime.parse(expiryDate).isAfter(DateTime.now());
}
