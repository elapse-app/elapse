import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:flutter/foundation.dart';

import '../../database/json_file_cache.dart';
import '../../main.dart';
import '../Filters/gradeLevel.dart';
import '../Filters/region.dart';
import '../Filters/season.dart';
import '../Miscellaneous/location.dart';
import "package:http/http.dart" as http;

class WorldSkillsStats {
  int teamId;
  String teamNum;
  String teamName;

  int rank;

  int score;
  int auton;
  int driver;

  int maxAuton;
  int maxDriver;

  Location? location;
  Region? eventRegion;

  WorldSkillsStats({
    required this.teamId,
    required this.teamNum,
    this.teamName = "",
    this.rank = 0,
    this.score = 0,
    this.auton = 0,
    this.driver = 0,
    this.maxAuton = 0,
    this.maxDriver = 0,
    this.location,
    this.eventRegion,
  });

  factory WorldSkillsStats.fromJson(Map<String, dynamic> json) {
    return WorldSkillsStats(
        teamId: json["team"]["id"],
        teamNum: json["team"]["team"],
        teamName: json["team"]["teamName"],
        rank: json["rank"],
        score: json["scores"]["score"],
        auton: json["scores"]["programming"],
        driver: json["scores"]["driver"],
        maxAuton: json["scores"]["maxProgramming"],
        maxDriver: json["scores"]["maxDriver"],
        location: Location(
          city: json["team"]["city"],
          region: json["team"]["region"],
          country: json["team"]["country"],
        ),
        eventRegion: Region(
          name:
              json["team"]["eventRegion"] == "British Columbia" ? "British Columbia (BC)" : json["team"]["eventRegion"],
          id: json["team"]["eventRegionId"],
        ));
  }
}

List<WorldSkillsStats> _parseWorldSkills(String body) =>
    (jsonDecode(body) as List).map((e) => WorldSkillsStats.fromJson(e)).toList();

class _CachedWorldSkills {
  final DateTime expiry;
  final List<WorldSkillsStats> rankings;

  _CachedWorldSkills(this.expiry, this.rankings);
}

final Map<String, _CachedWorldSkills> _worldSkillsMemory = {};
final Map<String, Future<List<WorldSkillsStats>>> _worldSkillsInFlight = {};
bool _clearedLegacyWorldSkillsPrefs = false;

String _worldSkillsKey(int seasonID, GradeLevel grade) => "world_skills_${seasonID}_${grade.id}";

/// The current season changes as events report. Past seasons are final.
Duration _worldSkillsTtl(int seasonID) =>
    seasonID == seasons[0].vrcId || seasonID == seasons[0].vexUId ? const Duration(hours: 2) : const Duration(days: 30);

/// World skills standings for a season and grade. Results are cached in memory
/// and on disk per (season, grade), and concurrent callers share one request.
/// If the network fails, an expired cached copy is returned when one exists.
Future<List<WorldSkillsStats>> getWorldSkillsRankings(int seasonID, GradeLevel grade) {
  if (seasonID < 115) {
    // Starstruck season ID (earliest season that had world skills data)
    return Future.value(List<WorldSkillsStats>.empty());
  }
  final cached = peekWorldSkillsRankings(seasonID, grade);
  if (cached != null) return Future.value(cached);

  final key = _worldSkillsKey(seasonID, grade);
  return _worldSkillsInFlight[key] ??= _loadWorldSkillsRankings(seasonID, grade, key).whenComplete(() {
    _worldSkillsInFlight.remove(key); // Block body: remove() returns this future, and returning it would self-await.
  });
}

/// Unexpired in-memory world skills for (season, grade), or null. Synchronous,
/// so build methods can use it without a FutureBuilder flash.
List<WorldSkillsStats>? peekWorldSkillsRankings(int seasonID, GradeLevel grade) {
  final cached = _worldSkillsMemory[_worldSkillsKey(seasonID, grade)];
  if (cached == null || !cached.expiry.isAfter(DateTime.now())) return null;
  return cached.rankings;
}

Future<List<WorldSkillsStats>> _loadWorldSkillsRankings(int seasonID, GradeLevel grade, String key) async {
  if (!_clearedLegacyWorldSkillsPrefs) {
    // The old single-slot cache kept a multi-MB string in SharedPreferences.
    _clearedLegacyWorldSkillsPrefs = true;
    for (final k in ["worldSkillsData", "worldSkillsExpiry", "worldSkillsGrade"]) {
      prefs.remove(k);
    }
  }

  final disk = await JsonFileCache.read(key);
  final diskExpiry = DateTime.tryParse("${disk?.meta["expiry"]}");
  if (disk != null && diskExpiry != null && diskExpiry.isAfter(DateTime.now())) {
    try {
      final rankings = await compute(_parseWorldSkills, disk.body);
      _worldSkillsMemory[key] = _CachedWorldSkills(diskExpiry, rankings);
      return rankings;
    } catch (_) {
      // Corrupt cache file. Fall through and fetch it again.
    }
  }

  try {
    final response = await http.get(
      Uri.parse("https://events.vex.com/api/seasons/$seasonID/skills")
          .replace(queryParameters: {"grade_level": grade.name}),
    );
    if (response.statusCode != 200) {
      throw Exception("World skills request failed (${response.statusCode})");
    }
    final rankings = await compute(_parseWorldSkills, response.body);
    final expiry = DateTime.now().add(_worldSkillsTtl(seasonID));
    _worldSkillsMemory[key] = _CachedWorldSkills(expiry, rankings);
    await JsonFileCache.write(key, {"expiry": expiry.toIso8601String()}, response.body);
    return rankings;
  } catch (e) {
    final stale = _worldSkillsMemory[key]?.rankings ??
        (disk != null ? await compute(_parseWorldSkills, disk.body).catchError((_) => <WorldSkillsStats>[]) : null);
    if (stale != null && stale.isNotEmpty) {
      debugPrint("World skills refresh failed, serving stale $key: $e");
      return stale;
    }
    rethrow;
  }
}

Future<WorldSkillsStats?> getWorldSkillsForTeam(int seasonID, int teamID) async {
  GradeLevel grade = (await fetchTeam(teamID)).grade!;
  List<WorldSkillsStats> rankings = await getWorldSkillsRankings(seasonID, grade);
  return rankings.singleWhereOrNull((e) => e.teamId == teamID);
}
