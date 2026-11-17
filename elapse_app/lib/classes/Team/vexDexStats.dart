import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../extras/token.dart';
import '../Filters/gradeLevel.dart';

const String _vexDexBaseUrl = "https://vexdex.fly.dev/api/v1";

Map<String, String> _vexDexHeaders() => {
      HttpHeaders.authorizationHeader: getVexDexToken(),
    };

class VexDexStats {
  int teamId;
  String teamNum;
  String? teamName;
  GradeLevel? gradeLevel;
  String? region;

  double oprAvg;
  double oprBest;
  double dprAvg;
  double dprBest;
  double ccwmAvg;
  double ccwmBest;

  int wins;
  int losses;
  int draws;
  int matches;
  double winPercent;

  double trueSkill;
  int trueSkillGlobalRank;
  int? trueSkillRegionRank;

  bool regionalQual;
  bool worldsQual;

  int? skillsScore;
  // skills_driver is the driver-component score from whichever single event
  // had the best combined driver+programming total for the season — NOT
  // independently maxed across the season like the old VDA maxDriver was.
  int? maxDriver;
  int? skillsProg;

  int? worldSkillsRank;
  int? regionSkillsRank;

  DateTime? updatedAt;

  VexDexStats({
    required this.teamId,
    required this.teamNum,
    required this.teamName,
    required this.gradeLevel,
    required this.region,
    required this.oprAvg,
    required this.oprBest,
    required this.dprAvg,
    required this.dprBest,
    required this.ccwmAvg,
    required this.ccwmBest,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.matches,
    required this.winPercent,
    required this.trueSkill,
    required this.trueSkillGlobalRank,
    required this.trueSkillRegionRank,
    required this.regionalQual,
    required this.worldsQual,
    this.skillsScore,
    this.maxDriver,
    this.skillsProg,
    this.worldSkillsRank,
    this.regionSkillsRank,
    this.updatedAt,
  });

  factory VexDexStats.fromJson(Map<String, dynamic> json) {
    return VexDexStats(
      teamId: (json["team_id"] as num).toInt(),
      teamNum: json["team_num"],
      teamName: json["team_name"],
      gradeLevel: gradeLevels[json["grade"]],
      region: json["region"],
      oprAvg: (json["opr_avg"] as num).toDouble(),
      oprBest: (json["opr_best"] as num).toDouble(),
      dprAvg: (json["dpr_avg"] as num).toDouble(),
      dprBest: (json["dpr_best"] as num).toDouble(),
      ccwmAvg: (json["ccwm_avg"] as num).toDouble(),
      ccwmBest: (json["ccwm_best"] as num).toDouble(),
      wins: (json["total_wins"] as num).toInt(),
      losses: (json["total_losses"] as num).toInt(),
      draws: (json["total_draws"] as num).toInt(),
      matches: (json["matches_played"] as num).toInt(),
      // VexDex's total_winrate is a 0.0-1.0 fraction; the UI displays 0-100%.
      winPercent: (json["total_winrate"] as num).toDouble() * 100,
      trueSkill: (json["ts_exposed"] as num).toDouble(),
      trueSkillGlobalRank: (json["ts_rank"] as num).toInt(),
      trueSkillRegionRank: (json["region_ts_rank"] as num?)?.toInt(),
      regionalQual: json["qualed_regionals"] as bool,
      worldsQual: json["qualed_worlds"] as bool,
      skillsScore: (json["skills_total"] as num?)?.toInt(),
      maxDriver: (json["skills_driver"] as num?)?.toInt(),
      skillsProg: (json["skills_prog"] as num?)?.toInt(),
      worldSkillsRank: (json["skills_global_rank"] as num?)?.toInt(),
      regionSkillsRank: (json["skills_region_rank"] as num?)?.toInt(),
      updatedAt: json["updated_at"] != null ? DateTime.tryParse(json["updated_at"]) : null,
    );
  }
}

class VexDexLeaderboardPage {
  final int total;
  final int limit;
  final int offset;
  final List<VexDexStats> items;

  VexDexLeaderboardPage({
    required this.total,
    required this.limit,
    required this.offset,
    required this.items,
  });
}

Future<VexDexStats?> getVexDexTeamByNumber(int seasonId, String teamNum) async {
  final response = await http.get(
    Uri.parse("$_vexDexBaseUrl/seasons/$seasonId/teams/by-number/${Uri.encodeComponent(teamNum)}"),
    headers: _vexDexHeaders(),
  );
  if (response.statusCode == 404) return null;
  if (response.statusCode != 200) {
    throw Exception("VexDex request failed (${response.statusCode}) for team $teamNum");
  }
  return VexDexStats.fromJson(jsonDecode(response.body));
}

Future<VexDexStats?> getVexDexTeamById(int seasonId, int teamId) async {
  final response = await http.get(
    Uri.parse("$_vexDexBaseUrl/seasons/$seasonId/teams/$teamId"),
    headers: _vexDexHeaders(),
  );
  if (response.statusCode == 404) return null;
  if (response.statusCode != 200) {
    throw Exception("VexDex request failed (${response.statusCode}) for team id $teamId");
  }
  return VexDexStats.fromJson(jsonDecode(response.body));
}

/// sort must be one of "ts" | "pick_list" | "ccwm" | "opr" — matches VexDex's
/// server-side sort options exactly (api.py's _LEADERBOARD_SORTS). There is
/// no server-side support for sorting by dpr or win percent.
///
/// [search], when given, case-insensitively matches teams whose number or
/// name contains the given substring (server-side, via VexDex's `search`
/// query param) — the result set is still ordered by [sort] on top of that.
Future<VexDexLeaderboardPage> getVexDexLeaderboard(
  int seasonId, {
  int limit = 100,
  int offset = 0,
  String sort = "ts",
  String? search,
}) async {
  final queryParams = {
    "limit": "$limit",
    "offset": "$offset",
    "sort": sort,
  };
  if (search != null && search.isNotEmpty) queryParams["search"] = search;
  final uri = Uri.parse("$_vexDexBaseUrl/seasons/$seasonId/teams").replace(queryParameters: queryParams);
  final response = await http.get(uri, headers: _vexDexHeaders());
  if (response.statusCode != 200) {
    throw Exception("VexDex leaderboard request failed (${response.statusCode})");
  }
  final body = jsonDecode(response.body);
  return VexDexLeaderboardPage(
    total: body["total"],
    limit: body["limit"],
    offset: body["offset"],
    items: (body["items"] as List).map((e) => VexDexStats.fromJson(e)).toList(),
  );
}

/// Runs [tasks] with at most [maxConcurrent] in flight at once. VexDex's
/// Postgres connection pool is small (5 + 5 overflow per gunicorn worker, 2
/// workers), so firing dozens-to-hundreds of requests at once — as happens
/// fetching every page of an archived season with 10,000+ teams — can
/// exhaust it and make the whole fetch fail or hang instead of just being
/// slower. Batching keeps arbitrarily large fetches reliable at the cost of
/// some wall-clock time.
Future<List<T>> _runBatched<T>(List<Future<T> Function()> tasks, {int maxConcurrent = 8}) async {
  final results = <T>[];
  for (var i = 0; i < tasks.length; i += maxConcurrent) {
    final batch = tasks.skip(i).take(maxConcurrent).map((task) => task());
    results.addAll(await Future.wait(batch));
  }
  return results;
}

/// For a bounded, already-known roster (e.g. one tournament's teams) — avoids
/// fetching the entire season leaderboard just to filter it down. A single
/// team's lookup failing (network hiccup, transient 5xx) is treated as "no
/// data for that team" rather than failing the whole roster — otherwise one
/// bad lookup would silently blank out every other team's data too.
Future<Map<String, VexDexStats>> getVexDexTeamsByNumber(int seasonId, List<String> teamNums) async {
  final results = await _runBatched(teamNums.map((n) => () async {
        try {
          return await getVexDexTeamByNumber(seasonId, n);
        } catch (e) {
          debugPrint("getVexDexTeamsByNumber: lookup failed for team $n: $e");
          return null;
        }
      }).toList());
  final Map<String, VexDexStats> map = {};
  for (var i = 0; i < teamNums.length; i++) {
    final r = results[i];
    if (r != null) map[teamNums[i]] = r;
  }
  return map;
}

/// Every team in a season's leaderboard — for world-rankings-style screens
/// that (like the Skills tab they sit alongside) load the whole dataset once
/// rather than paging through it. Fetches the first page to learn `total`,
/// then fetches the remaining offset-based pages in bounded-concurrency
/// batches (see [_runBatched]) — a completed/archived season can have
/// 10,000+ teams (25+ pages), so this can't safely fire every page at once.
Future<List<VexDexStats>> getAllVexDexTeams(int seasonId, {String sort = "ts"}) async {
  const pageSize = 500; // VexDex's max `limit` per request.
  final first = await getVexDexLeaderboard(seasonId, limit: pageSize, offset: 0, sort: sort);
  if (first.total <= first.items.length) return first.items;

  final remainingOffsets = <int>[
    for (var offset = pageSize; offset < first.total; offset += pageSize) offset,
  ];
  final rest = await _runBatched(
    remainingOffsets.map((offset) => () => getVexDexLeaderboard(seasonId, limit: pageSize, offset: offset, sort: sort)).toList(),
  );

  final all = <VexDexStats>[...first.items];
  for (final page in rest) {
    all.addAll(page.items);
  }
  return all;
}
