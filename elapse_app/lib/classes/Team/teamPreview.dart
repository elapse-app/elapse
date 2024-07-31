import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;

class TeamPreview {
  String teamNumber;
  int teamID;
  Location? location;
  String? teamName;

  TeamPreview(
      {required this.teamNumber,
      required this.teamID,
      this.location,
      this.teamName});
}

Future<List<TeamPreview>> fetchTeamPreview(String searchQuery) async {
  List<TeamPreview> teams = [];
  Completer<void> robotEventsCompleter = Completer<void>();
  Completer<void> vdaStatsCompleter = Completer<void>();

  Future<void> robotEventsResponse = http.get(
    Uri.parse(
        'https://www.robotevents.com/api/v2/teams?number%5B%5D=$searchQuery&program%5B%5D=1&program%5B%5D=4&myTeams=false'),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
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
            )));

        if (!vdaStatsCompleter.isCompleted) {
          vdaStatsCompleter.complete();
        }
      }
      if (!robotEventsCompleter.isCompleted) {
        robotEventsCompleter.complete();
      }
    } else {
      throw Exception('Failed to load team preview');
    }
  });

  getTrueSkillData().then((value) {
    if (!vdaStatsCompleter.isCompleted) {
      List<TeamPreview> vdaTeams = value.where((element) {
        if (searchQuery.isEmpty) {
          return false;
        }
        if (element.teamName != null) {
          return element.teamNum
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              element.teamName!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        } else {
          return element.teamNum.contains(searchQuery.toLowerCase());
        }
      }).map((e) {
        return TeamPreview(
            teamNumber: e.teamNum,
            teamID: e.id,
            location: e.location,
            teamName: e.teamName);
      }).toList();

      teams.addAll(vdaTeams);
      if (!robotEventsCompleter.isCompleted && vdaTeams.isNotEmpty) {
        robotEventsCompleter.complete();
      }

      if (!vdaStatsCompleter.isCompleted && vdaTeams.isNotEmpty) {
        vdaStatsCompleter.complete();
      }
    }
  });

  await Future.any([robotEventsCompleter.future, vdaStatsCompleter.future]);
  return teams;
}
