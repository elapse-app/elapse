import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/seasonStats.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/requests/token.dart';
import 'package:elapse_app/requests/trueSkillHandler.dart';
import 'package:http/http.dart' as http;

Future<Team> fetchTeam(int teamId) async {
  // Fetch team data
  final mainInfo = http.get(
    Uri.parse("https://www.robotevents.com/api/v2/teams/$teamId"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  final loadedMainInfo = await mainInfo;
  final parsedMainInfo = (jsonDecode(loadedMainInfo.body));
  String teamName = parsedMainInfo["team_name"];
  String teamNumber = parsedMainInfo["number"];
  String organization = parsedMainInfo["organization"];
  String grade = parsedMainInfo["grade"];
  Location location = Location(
      address1: parsedMainInfo["address_1"],
      address2: parsedMainInfo["address_2"],
      city: parsedMainInfo["city"],
      region: parsedMainInfo["region"],
      country: parsedMainInfo["country"]);

  return Team(
    id: teamId,
    teamName: teamName,
    teamNumber: teamNumber,
    organization: organization,
    location: location,
    grade: grade,
  );
}

Future<SeasonStats> fetchTeamSeasonStats(int teamId, int seasonID) async {
  // Fetch team data
  final awardInfo = http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/teams/$teamId/awards?season%5B%5D=$seasonID?per_page=100"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  final seasonStatInfo = getTrueSkillDataForTeam(teamId);

  final loadedAwardInfo = await awardInfo;
  final parsedAwardInfo = jsonDecode(loadedAwardInfo.body)["data"] as List;
  List<Award> awards = parsedAwardInfo.map<Award>((award) {
    final splitAward = award["title"].split(" ");
    String awardName = "";
    for (int i = 0; i < splitAward.length; i++) {
      if (splitAward[i] != "(VRC/VEXU/VAIRC)") {
        awardName += splitAward[i] + " ";
      }
    }
    awardName = awardName.trim();
    return Award(
      name: awardName,
      tournament: TournamentPreview(
        id: award["event"]["id"],
        name: award["event"]["name"],
      ),
      qualifications: List<String>.from(award["qualifications"]),
      team: null,
    );
  }).toList();

  final loadedSeasonStatInfo = await seasonStatInfo;

  SeasonStats seasonStats =
      SeasonStats(awards: awards, vdaStats: loadedSeasonStatInfo);

  return seasonStats;
}

Future<List<TournamentPreview>> fetchTeamTournaments(
    int teamId, int seasonID) async {
  // Fetch team data

  final tournamentInfo = http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/teams/$teamId/events?season%5B%5D=$seasonID"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  final loadedTournamentInfo = await tournamentInfo;
  final parsedTournamentInfo = jsonDecode(loadedTournamentInfo.body) as List;
  List<TournamentPreview> tournaments = parsedTournamentInfo
      .map<TournamentPreview>((tournament) => TournamentPreview(
            id: tournament["id"],
            name: tournament["name"],
            location: Location(
                address1: tournament["address_1"],
                address2: tournament["address_2"],
                city: tournament["city"],
                region: tournament["region"],
                country: tournament["country"],
                venue: tournament["venue"]),
            startDate: tournament["start"],
            endDate: tournament["end"],
          ))
      .toList();

  return tournaments;
}
