import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/vexDexStats.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../Filters/gradeLevel.dart';
import '../Filters/season.dart';

class TeamPreview {
  String teamNumber;
  int teamID;
  Location? location;
  String? teamName;
  GradeLevel? gradeLevel;

  TeamPreview(
      {required this.teamNumber,
      required this.teamID,
      this.location,
      this.teamName,
      this.gradeLevel,});

  Map<String, dynamic> toJson() {
    return {
      'teamNumber': teamNumber,
      'teamID': teamID,
      'location': location?.toJson(),
      'teamName': teamName,
      'grade': gradeLevel?.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamPreview && other.teamID == teamID;
  }

  @override
  int get hashCode => teamNumber.hashCode;
}

TeamPreview loadTeamPreview(teamPreview) {
  dynamic preview = jsonDecode(teamPreview);
  return TeamPreview(
    teamNumber: preview["teamNumber"],
    teamID: preview["teamID"],
    location:
        preview["location"] != null ? loadLocation(preview["location"]) : null,
    teamName: preview["teamName"],
    gradeLevel: gradeLevels[preview["grade"]],
  );
}

Future<List<TeamPreview>> fetchTeamPreview(String searchQuery) async {
  final results = await Future.wait([
    _fetchVexEventsTeam(searchQuery),
    _fetchVexDexTeams(searchQuery),
  ]);

  return results.expand((r) => r).toSet().toList();
}

const Duration _teamSearchTimeout = Duration(seconds: 10);

Future<List<TeamPreview>> _fetchVexEventsTeam(String searchQuery) async {
  try {
    final response = await http.get(
      Uri.parse(
          'https://events.vex.com/api/v2/teams?number%5B%5D=$searchQuery&program%5B%5D=1&program%5B%5D=4&myTeams=false'),
      headers: {
        HttpHeaders.authorizationHeader: getToken(),
      },
    ).timeout(_teamSearchTimeout);
    if (response.statusCode != 200) {
      debugPrint("VEX Events team search failed (${response.statusCode}) for '$searchQuery'");
      return [];
    }
    final responseData = jsonDecode(response.body)["data"];
    if (responseData.isEmpty) return [];
    return [
      TeamPreview(
        teamNumber: responseData[0]["number"],
        teamID: responseData[0]["id"],
        teamName: responseData[0]["team_name"],
        location: Location(
          address1: responseData[0]["location"]["address_1"],
          address2: responseData[0]["location"]["address_2"],
          city: responseData[0]["location"]["city"],
          region: responseData[0]["location"]["region"],
          country: responseData[0]["location"]["country"],
          venue: responseData[0]["location"]["venue"],
        ),
        gradeLevel: gradeLevels[responseData[0]["grade"]],
      )
    ];
  } catch (e) {
    debugPrint("VEX Events team search failed for '$searchQuery': $e");
    return [];
  }
}

Future<List<TeamPreview>> _fetchVexDexTeams(String searchQuery) async {
  if (searchQuery.isEmpty) return [];
  try {
    final page = await getVexDexLeaderboard(seasons[0].vrcId, search: searchQuery, limit: 20)
        .timeout(_teamSearchTimeout);
    return page.items
        .map((team) => TeamPreview(
              teamNumber: team.teamNum,
              teamID: team.teamId,
              location: team.region != null ? Location(region: team.region) : null,
              teamName: team.teamName,
              gradeLevel: team.gradeLevel,
            ))
        .toList();
  } catch (e) {
    debugPrint("VexDex team search failed for '$searchQuery': $e");
    return [];
  }
}
