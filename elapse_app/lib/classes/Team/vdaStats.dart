import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/extras/async_cache.dart';
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
      winPercent: double.tryParse(
          json["total_winning_percent"]?.toStringAsFixed(1) ?? ""),
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
    final wins =
        _number(json['total_wins']) + _number(json['elimination_wins']);
    final losses =
        _number(json['total_losses']) + _number(json['elimination_losses']);
    final ties =
        _number(json['total_ties']) + _number(json['elimination_ties']);
    final matches = wins + losses + ties;

    return VDAStats(
      id: _number(json['team_id']).toInt(),
      teamNum: json['team_num']?.toString() ?? '',
      teamName: json['team_name']?.toString(),
      gradeLevel: null,
      opr: _nullableDouble(json['opr']),
      dpr: _nullableDouble(json['dpr']),
      ccwm: _nullableDouble(json['ccwm']),
      wins: wins.toInt(),
      losses: losses.toInt(),
      ties: ties.toInt(),
      matches: matches.toInt(),
      winPercent: matches == 0
          ? 0
          : double.parse((wins / matches * 100).toStringAsFixed(1)),
      trueSkill: _nullableDouble(json['trueskill']),
      trueSkillGlobalRank: _nullableNumber(json['ts_ranking'])?.toInt(),
      trueSkillRegionRank: 0,
      regionalQual: 0,
      worldsQual: 0,
      eventRegion: "",
    );
  }
}

final _trueSkillCache = AsyncCache<int, List<VDAStats>>(
  timeToLive: const Duration(hours: 2),
);

Future<List<VDAStats>> getTrueSkillData(int seasonId) async {
  if (seasonId < 154) {
    return const [];
  }

  try {
    return await _trueSkillCache.get(
      seasonId,
      () => _loadTrueSkillData(seasonId),
    );
  } catch (_) {
    // VDA is optional. Keep failures out of the cache so a later call can
    // recover as soon as the service is reachable again.
    return const [];
  }
}

Future<List<VDAStats>> _loadTrueSkillData(int seasonId) async {
  final vdaData = prefs.getString('vdaData');

  if (seasonId != seasons[0].vrcId) {
    final response = await http
        .get(
          Uri.parse(
            'https://vrc-data-analysis.com/v1/historical_allteams/$seasonId',
          ),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw StateError('VDA request failed (${response.statusCode})');
    }
    final parsed = jsonDecode(response.body);
    if (parsed is! List) {
      throw const FormatException('Unexpected historical VDA response.');
    }
    return List.unmodifiable(
      parsed.whereType<Map<String, dynamic>>().map(VDAStats.fromHistorical),
    );
  }

  late final List<dynamic> parsed;
  if (!hasCachedTrueSkillData()) {
    final response = await http
        .get(Uri.parse('https://vrc-data-analysis.com/v1/allteams'))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw StateError('VDA request failed (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Unexpected VDA response.');
    }
    parsed = decoded;
    await Future.wait([
      prefs.setString('vdaData', response.body),
      prefs.setString(
        'vdaExpiry',
        DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
      ),
    ]);
  } else {
    final decoded = jsonDecode(vdaData!);
    if (decoded is! List) {
      throw const FormatException('Invalid cached VDA response.');
    }
    parsed = decoded;
  }

  return List.unmodifiable(
    parsed.whereType<Map<String, dynamic>>().map(VDAStats.fromJson),
  );
}

Future<VDAStats?> getTrueSkillDataForTeam(int seasonId, String teamNum) async {
  final response = await getTrueSkillData(seasonId);
  for (final team in response) {
    if (team.teamName == teamNum || team.teamNum == teamNum) {
      return team;
    }
  }
  return null;
}

bool hasCachedTrueSkillData() {
  final String? vdaData = prefs.getString("vdaData");
  final String? expiryDate = prefs.getString("vdaExpiry");

  if (vdaData == null || expiryDate == null) {
    return false;
  }
  return DateTime.tryParse(expiryDate)?.isAfter(DateTime.now()) ?? false;
}

num _number(Object? value) => _nullableNumber(value) ?? 0;

num? _nullableNumber(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

double? _nullableDouble(Object? value) => _nullableNumber(value)?.toDouble();
