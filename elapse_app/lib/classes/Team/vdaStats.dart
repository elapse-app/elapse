import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VDAStats {
  int id = 0;
  String teamNum;
  double opr;
  double dpr;
  double ccwm;

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

  String? region;

  num? skillsScore;
  num? maxAuto;
  num? maxDriver;

  num? worldSkillsRank;
  num? regionSkillsRank;

  VDAStats({
    required this.teamNum,
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
    required this.region,
    this.skillsScore,
    this.maxAuto,
    this.maxDriver,
    this.worldSkillsRank,
    this.regionSkillsRank,
  });

  factory VDAStats.fromJson(Map<String, dynamic> json) {
    return VDAStats(
      teamNum: json["team_number"],
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
      region: json["loc_region"],
      skillsScore: json["score_total_max"]?.truncate(),
      maxAuto: json["score_auto_max"]?.truncate(),
      maxDriver: json["score_driver_max"]?.truncate(),
      worldSkillsRank: json["total_skills_ranking"]?.truncate(),
      regionSkillsRank: json["region_grade_skills_rank"]?.truncate(),
    );
  }
}

Future<List<VDAStats>> getTrueSkillData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove("vdaData");
  prefs.remove("vdaExpiry");
  final String? vdaData = prefs.getString("vdaData");
  final String? expiryDate = prefs.getString("vdaExpiry");

  List<dynamic> parsed = [];

  if (vdaData == null ||
      expiryDate == null ||
      DateTime.parse(expiryDate).isBefore(DateTime.now())) {
    print("getting new data");
    final response = await http.get(
      Uri.parse("https://vrc-data-analysis.com/v1/historical_allteams/181"),
    );

    parsed = jsonDecode(response.body) as List;
    print(parsed);
    prefs.setString("vdaData", response.body);
    prefs.setString("vdaExpiry",
        DateTime.now().add(const Duration(minutes: 20)).toString());
    parsed = jsonDecode(response.body) as List;
  } else {
    print("getting cached data");
    parsed = jsonDecode(vdaData) as List;
  }

  List<VDAStats> vdaStats =
      parsed.map<VDAStats>((json) => VDAStats.fromJson(json)).toList();
  return vdaStats;
}

Future<VDAStats> getTrueSkillDataForTeam(String teamNum) async {
  final response = await getTrueSkillData();
  return response.firstWhere((element) => element.teamNum == teamNum);
}
