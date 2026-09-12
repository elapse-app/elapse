import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/vexDexStats.dart';
import 'package:elapse_app/extras/token.dart';
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
  List<TeamPreview> teams = [];
  Completer<void> robotEventsCompleter = Completer<void>();
  Completer<void> vexDexCompleter = Completer<void>();

  http.get(
    Uri.parse(
        'https://events.vex.com/api/v2/teams?number%5B%5D=$searchQuery&program%5B%5D=1&program%5B%5D=4&myTeams=false'),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  ).then((response) {
    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body)["data"];
      if (responseData.isNotEmpty) {
        teams.add(TeamPreview(
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
        ));

        if (!vexDexCompleter.isCompleted) {
          vexDexCompleter.complete();
        }
      }
      if (!robotEventsCompleter.isCompleted) {
        robotEventsCompleter.complete();
      }
    } else {
      throw Exception('Failed to load team preview');
    }
  });

  // VexDex has no substring/name search, only exact-number lookup — this
  // fallback only catches "typed an exact team number RobotEvents missed",
  // not the old partial-name-match search VDA used to support.
  if (searchQuery.isNotEmpty) {
    getVexDexTeamByNumber(seasons[0].vrcId, searchQuery.toUpperCase()).then((team) {
      if (!vexDexCompleter.isCompleted && team != null) {
        teams.add(TeamPreview(
          teamNumber: team.teamNum,
          teamID: team.teamId,
          location: team.region != null ? Location(region: team.region) : null,
          teamName: team.teamName,
          gradeLevel: team.gradeLevel,
        ));

        if (!robotEventsCompleter.isCompleted) {
          robotEventsCompleter.complete();
        }
        vexDexCompleter.complete();
      }
    });
  }

  await Future.any([robotEventsCompleter.future, vexDexCompleter.future]);
  // remove duplicates from teams
  // Remove duplicates based on teamNumber
  final uniqueTeams = teams.toSet();
  teams = uniqueTeams.toList();

  return teams;
}
