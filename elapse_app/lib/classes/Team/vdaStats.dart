import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/main.dart';
import 'package:http/http.dart' as http;

import '../Filters/season.dart';

class VDAStats {
  int id;
  String teamNum;
  String? teamName;
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
      id: json["id"],
      teamNum: json["team_number"],
      teamName: json["team_name"],
      opr: json["opr"],
      dpr: json["dpr"],
      ccwm: json["ccwm"],
      wins: json["total_wins"]?.truncate(),
      losses: json["total_losses"]?.truncate(),
      ties: json["total_ties"]?.truncate(),
      matches: json["total_matches"]?.truncate(),
      winPercent: json["total_winning_percent"],
      trueSkill: json["trueskill"],
      trueSkillGlobalRank: json["ts_ranking"],
      trueSkillRegionRank: json["ts_ranking_region"],
      regionalQual: json["qualified_for_regionals"],
      worldsQual: json["qualified_for_worlds"],
      eventRegion: json["event_region"] == "British Columbia"
          ? "British Columbia (BC)"
          : json["event_region"],
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
      opr: json["opr"],
      dpr: json["dpr"],
      ccwm: json["ccwm"],
      wins: json["total_wins"]?.truncate(),
      losses: json["total_losses"]?.truncate(),
      ties: json["total_ties"]?.truncate(),
      matches: ((json["total_wins"] ?? 0) + (json["total_losses"] ?? 0) + (json["total_ties"] ?? 0))?.truncate() ?? 0,
      winPercent: (json["total_wins"] ?? 0) / (((json["total_wins"] ?? 0) + (json["total_losses"] ?? 0) + (json["total_ties"] ?? 0)) == 0 ? 1 : ((json["total_wins"] ?? 0) + (json["total_losses"] ?? 0) + (json["total_ties"] ?? 0))) * 100,
      trueSkill: json["trueskill"],
      trueSkillGlobalRank: json["ts_ranking"]?.truncate(),
      trueSkillRegionRank: 0,
      regionalQual: 0,
      worldsQual: 0,
      eventRegion: "",
    );
  }
}

Future<List<VDAStats>> getTrueSkillData(seasonId) async {
  final String? vdaData = prefs.getString("vdaData");
  final String? expiryDate = prefs.getString("vdaExpiry");

  List<dynamic> parsed = [];

  if (seasonId < seasons[3].vrcId) {
    return List<VDAStats>.empty();
  }

  if (seasonId != seasons[0].vrcId) {
    final response = await http.get(
      Uri.parse("https://vrc-data-analysis.com/v1/historical_allteams/$seasonId"),
    );
    parsed = jsonDecode(response.body) as List;

    List<VDAStats> vdaStats = parsed.map<VDAStats>((json) => VDAStats.fromHistorical(json)).toList();
    return vdaStats;
  } else if (vdaData == null ||
      expiryDate == null ||
      DateTime.parse(expiryDate).isBefore(DateTime.now())) {
    final response = await http.get(
        Uri.parse("https://vrc-data-analysis.com/v1/allteams"),
      );

    parsed = jsonDecode(response.body) as List;
    prefs.setString("vdaData", response.body);
    prefs.setString(
        "vdaExpiry", DateTime.now().add(const Duration(hours: 2)).toString());
  } else {
    parsed = jsonDecode(vdaData) as List;
  }

  List<VDAStats> vdaStats =
      parsed.map<VDAStats>((json) => VDAStats.fromJson(json)).toList();
  return vdaStats;
}

Future<VDAStats> getTrueSkillDataForTeam(String teamNum) async {
  final response = await getTrueSkillData(seasons[0].vrcId);
  return response.firstWhere((element) => element.teamNum == teamNum);
}
