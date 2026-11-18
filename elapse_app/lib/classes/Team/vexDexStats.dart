import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../database/json_file_cache.dart';
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

  /// One row of the compact /seasons/{id}/leaderboard response, where [col]
  /// maps column name to index. It carries only what World Rankings shows.
  /// Every other field gets a neutral default, and the team screen fetches
  /// full stats on its own.
  factory VexDexStats.fromLeaderboardRow(List row, Map<String, int> col) {
    T? at<T>(String name) {
      final i = col[name];
      return i == null ? null : row[i] as T?;
    }

    double num0(String name) => (at<num>(name) ?? 0).toDouble();

    return VexDexStats(
      teamId: (at<num>("team_id") ?? 0).toInt(),
      teamNum: at<String>("team_num") ?? "",
      teamName: at<String>("team_name"),
      gradeLevel: gradeLevels[at<String>("grade")],
      region: at<String>("region"),
      oprAvg: num0("opr_avg"),
      oprBest: 0,
      dprAvg: num0("dpr_avg"),
      dprBest: 0,
      ccwmAvg: num0("ccwm_avg"),
      ccwmBest: 0,
      wins: 0,
      losses: 0,
      draws: 0,
      matches: (at<num>("matches_played") ?? 0).toInt(),
      winPercent: num0("total_winrate") * 100,
      trueSkill: num0("ts_exposed"),
      trueSkillGlobalRank: (at<num>("ts_rank") ?? 0).toInt(),
      trueSkillRegionRank: at<num>("region_ts_rank")?.toInt(),
      regionalQual: false,
      worldsQual: false,
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
/// workers), so firing a whole tournament roster's lookups at once can exhaust
/// it and make the fetch fail or hang instead of just being slower.
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
  final results = await _runBatched(teamNums
      .map((n) => () async {
            try {
              return await getVexDexTeamByNumber(seasonId, n);
            } catch (e) {
              debugPrint("getVexDexTeamsByNumber: lookup failed for team $n: $e");
              return null;
            }
          })
      .toList());
  final Map<String, VexDexStats> map = {};
  for (var i = 0; i < teamNums.length; i++) {
    final r = results[i];
    if (r != null) map[teamNums[i]] = r;
  }
  return map;
}

// --- Whole-season leaderboard (World Rankings) ---------------------------------
//
// GET /seasons/{id}/leaderboard returns every team in a season in one compact
// response: only the columns World Rankings reads, as positional rows, served
// gzipped. VexDex data changes weekly, so the response is cached in memory and
// on disk and revalidated with its ETag. Usually the answer is a bodyless 304.

/// Parses a /leaderboard body. Runs in a background isolate via [compute].
List<VexDexStats> _parseCompactLeaderboard(String body) {
  final decoded = jsonDecode(body) as Map<String, dynamic>;
  final columns = (decoded["columns"] as List).cast<String>();
  final col = {for (var i = 0; i < columns.length; i++) columns[i]: i};
  return (decoded["rows"] as List).map((row) => VexDexStats.fromLeaderboardRow(row as List, col)).toList();
}

class _CachedLeaderboard {
  final String etag;
  final List<VexDexStats> teams;
  DateTime validatedAt;

  _CachedLeaderboard(this.etag, this.teams, this.validatedAt);
}

/// Within this window a season already in memory is returned with no request at all.
const _leaderboardRevalidateAfter = Duration(minutes: 10);
const _maxSeasonsInMemory = 3;
// Insertion-ordered, so the oldest entry is first: a small LRU.
final Map<int, _CachedLeaderboard> _leaderboardMemory = {};
final Map<int, Future<List<VexDexStats>>> _leaderboardInFlight = {};
final Map<int, Future<_CachedLeaderboard?>> _leaderboardDiskReads = {};

String _leaderboardCacheKey(int seasonId) => "vexdex_lb_$seasonId";

void _rememberLeaderboard(int seasonId, _CachedLeaderboard entry) {
  _leaderboardMemory.remove(seasonId);
  _leaderboardMemory[seasonId] = entry;
  while (_leaderboardMemory.length > _maxSeasonsInMemory) {
    _leaderboardMemory.remove(_leaderboardMemory.keys.first);
  }
}

bool _clearedLegacyLeaderboardCache = false;

/// Loads the disk copy into memory, unvalidated (validatedAt = epoch). Concurrent
/// callers share one read.
Future<_CachedLeaderboard?> _leaderboardFromDisk(int seasonId) {
  final memory = _leaderboardMemory[seasonId];
  if (memory != null) return Future.value(memory);
  return _leaderboardDiskReads[seasonId] ??= () async {
    final disk = await JsonFileCache.read(_leaderboardCacheKey(seasonId));
    final etag = disk?.meta["etag"];
    if (disk == null || etag is! String) return null;
    try {
      final teams = await compute(_parseCompactLeaderboard, disk.body);
      // A network load may have landed while this was parsing. Keep that one.
      return _leaderboardMemory[seasonId] ??= _CachedLeaderboard(etag, teams, DateTime.fromMillisecondsSinceEpoch(0));
    } catch (e) {
      debugPrint("VexDex leaderboard cache for season $seasonId is corrupt: $e");
      return null;
    }
  }()
      .whenComplete(() {
    _leaderboardDiskReads
        .remove(seasonId); // Block body: remove() returns this future, and returning it would self-await.
  });
}

/// The last-known leaderboard for [seasonId] from memory or disk, with no
/// network request. Null if nothing is cached. It may be stale, so pair it with
/// [getAllVexDexTeams] to show something right away and then refresh.
Future<List<VexDexStats>?> getCachedVexDexTeams(int seasonId) async => (await _leaderboardFromDisk(seasonId))?.teams;

/// Every team in a season's leaderboard, for World Rankings. Returns the memory
/// copy if it was validated in the last [_leaderboardRevalidateAfter].
/// Otherwise it makes one conditional request: a 304 keeps the cached copy, and
/// a 200 replaces it. If the network fails, any cached copy is returned.
/// Concurrent calls share one load. When nothing changed, the result is the
/// same list instance [getCachedVexDexTeams] returned, so callers can skip a
/// rebuild with `identical`.
Future<List<VexDexStats>> getAllVexDexTeams(int seasonId) {
  return _leaderboardInFlight[seasonId] ??= _loadAllVexDexTeams(seasonId).whenComplete(() {
    _leaderboardInFlight
        .remove(seasonId); // Block body: remove() returns this future, and returning it would self-await.
  });
}

Future<List<VexDexStats>> _loadAllVexDexTeams(int seasonId) async {
  if (!_clearedLegacyLeaderboardCache) {
    _clearedLegacyLeaderboardCache = true;
    JsonFileCache.deleteWhere((key) => key.startsWith("vexdex_leaderboard_")).ignore();
  }

  final memory = _leaderboardMemory[seasonId];
  if (memory != null && DateTime.now().difference(memory.validatedAt) < _leaderboardRevalidateAfter) {
    _rememberLeaderboard(seasonId, memory);
    return memory.teams;
  }

  final cached = await _leaderboardFromDisk(seasonId);
  try {
    final response = await http.get(
      Uri.parse("$_vexDexBaseUrl/seasons/$seasonId/leaderboard"),
      headers: {
        ..._vexDexHeaders(),
        if (cached != null) HttpHeaders.ifNoneMatchHeader: cached.etag,
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 304 && cached != null) {
      cached.validatedAt = DateTime.now();
      _rememberLeaderboard(seasonId, cached);
      return cached.teams;
    }
    if (response.statusCode == 404) {
      return const [];
    }
    if (response.statusCode != 200) {
      throw Exception("VexDex leaderboard request failed (${response.statusCode})");
    }

    final teams = await compute(_parseCompactLeaderboard, response.body);
    final etag = response.headers[HttpHeaders.etagHeader];
    _rememberLeaderboard(seasonId, _CachedLeaderboard(etag ?? "", teams, DateTime.now()));
    if (etag != null) {
      await JsonFileCache.write(_leaderboardCacheKey(seasonId), {"etag": etag}, response.body);
    }
    return teams;
  } catch (e) {
    if (cached != null) {
      debugPrint("VexDex leaderboard refresh failed, serving cached season $seasonId: $e");
      return cached.teams;
    }
    rethrow;
  }
}
