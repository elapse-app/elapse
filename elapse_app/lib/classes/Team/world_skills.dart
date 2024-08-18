import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Filters/region.dart';
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
        name: json["team"]["eventRegion"] == "British Columbia" ? "British Columbia (BC)" : json["team"]["eventRegion"],
        id: json["team"]["eventRegionId"],
      )
    );
  }
}

Future<List<WorldSkillsStats>> getWorldSkillsRankings(int seasonID) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? worldSkillsData = prefs.getString("worldSkillsData");
  final String? expiryDate = prefs.getString("worldSkillsExpiry");

  List<dynamic> parsed = [];

  if (worldSkillsData == null ||
      expiryDate == null ||
      DateTime.parse(expiryDate).isBefore(DateTime.now())) {
    final response = await http.get(
      Uri.parse("https://www.robotevents.com/api/seasons/$seasonID/skills"),
    );

    parsed = jsonDecode(response.body) as List;
    prefs.setString("worldSkillsData", response.body);
    prefs.setString("worldSkillsExpiry",
        DateTime.now().add(const Duration(hours: 2)).toString());
  } else {
    parsed = jsonDecode(worldSkillsData) as List;
  }

  List<WorldSkillsStats> ranking =
      parsed.map((e) => WorldSkillsStats.fromJson(e)).toList();
  return ranking;
}
