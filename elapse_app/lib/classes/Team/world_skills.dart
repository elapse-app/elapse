import 'dart:convert';

import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/extras/async_cache.dart';

import '../../main.dart';
import '../Filters/gradeLevel.dart';
import '../Filters/region.dart';
import '../Filters/season.dart';
import '../Miscellaneous/location.dart';
import "package:http/http.dart" as http;

class WorldSkillsStats {
  final int teamId;
  final String teamNum;
  final String teamName;

  final int rank;

  final int score;
  final int auton;
  final int driver;

  final int maxAuton;
  final int maxDriver;

  final Location? location;
  final Region? eventRegion;

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
          name: json["team"]["eventRegion"] == "British Columbia"
              ? "British Columbia (BC)"
              : json["team"]["eventRegion"],
          id: json["team"]["eventRegionId"],
        ));
  }
}

final _worldSkillsCache = AsyncCache<String, List<WorldSkillsStats>>(
  timeToLive: const Duration(hours: 2),
);

Future<List<WorldSkillsStats>> getWorldSkillsRankings(
    int seasonID, GradeLevel grade) {
  if (seasonID < 115) {
    // Starstruck season ID (earliest season that had world skills data)
    return Future.value(const []);
  }

  return _worldSkillsCache.get(
    '$seasonID:${grade.id}',
    () => _loadWorldSkillsRankings(seasonID, grade),
  );
}

Future<List<WorldSkillsStats>> _loadWorldSkillsRankings(
  int seasonID,
  GradeLevel grade,
) async {
  final worldSkillsData = prefs.getString('worldSkillsData');
  late final List<dynamic> parsed;
  final usesSharedPreferences = seasonID ==
          (grade == gradeLevels["College"]
              ? seasons[0].vexUId
              : seasons[0].vrcId) &&
      grade == getGradeLevel(prefs.getString('defaultGrade'));

  if (usesSharedPreferences && hasCachedWorldSkillsRankings(seasonID, grade)) {
    final decoded = jsonDecode(worldSkillsData!);
    if (decoded is! List) {
      throw const FormatException('Invalid cached world skills response.');
    }
    parsed = decoded;
  } else {
    final response = await http
        .get(
          Uri.https(
            'events.vex.com',
            '/api/seasons/$seasonID/skills',
            {'grade_level': grade.name},
          ),
        )
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw StateError(
        'World skills request failed (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Unexpected world skills response.');
    }
    parsed = decoded;
    if (usesSharedPreferences) {
      await Future.wait([
        prefs.setString('worldSkillsData', response.body),
        prefs.setString(
          'worldSkillsExpiry',
          DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
        ),
        prefs.setString('worldSkillsGrade', grade.name),
      ]);
    }
  }

  return List.unmodifiable(
    parsed.whereType<Map<String, dynamic>>().map(WorldSkillsStats.fromJson),
  );
}

Future<WorldSkillsStats> getWorldSkillsForTeam(int seasonID, int teamID) async {
  GradeLevel grade = (await fetchTeam(teamID)).grade!;
  List<WorldSkillsStats> rankings =
      await getWorldSkillsRankings(seasonID, grade);
  return rankings.singleWhere((e) => e.teamId == teamID);
}

bool hasCachedWorldSkillsRankings(int seasonID, GradeLevel grade) {
  if (seasonID !=
          (grade == gradeLevels["College"]
              ? seasons[0].vexUId
              : seasons[0].vrcId) ||
      grade != getGradeLevel(prefs.getString("defaultGrade"))) {
    return false;
  }

  final String? worldSkillsData = prefs.getString("worldSkillsData");
  final String? expiryDate = prefs.getString("worldSkillsExpiry");
  final String? cachedGrade = prefs.getString("worldSkillsGrade");

  return worldSkillsData != null &&
      expiryDate != null &&
      cachedGrade != null &&
      (DateTime.tryParse(expiryDate)?.isAfter(DateTime.now()) ?? false) &&
      grade == gradeLevels[cachedGrade];
}
