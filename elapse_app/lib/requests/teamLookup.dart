import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/seasonStats.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/requests/trueSkillHandler.dart';
import 'package:http/http.dart' as http;

Future<Team> fetchTeam(int teamId) async {
  // Fetch team data
  final mainInfo = http.get(
    Uri.parse("https://www.robotevents.com/api/v2/teams/$teamId"),
    headers: {
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
    },
  );

  final loadedMainInfo = await mainInfo;
  final parsedMainInfo = (jsonDecode(loadedMainInfo.body));
  print(parsedMainInfo);
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
        "https://www.robotevents.com/api/v2/teams/$teamId/awards?season%5B%5D=$seasonID"),
    headers: {
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
    },
  );

  final seasonStatInfo = getTrueSkillDataForTeam(teamId);

  final loadedAwardInfo = await awardInfo;
  final parsedAwardInfo = jsonDecode(loadedAwardInfo.body)["data"] as List;
  List<Award> awards = parsedAwardInfo.map<Award>((award) {
    final splitAward = award["title"].split(" ");
    print(splitAward);
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
      HttpHeaders.authorizationHeader:
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzIiwianRpIjoiMTM4MmM0Y2Y4NTUxNGM1NzYwMDI5MDhlNWMzZWM2ODNkOGUwYzIwMWNiNjJjNThjYTQwZjc3MmI5YWYzOTE0ZGJiMDFhMGZmYWNjNWI3Y2UiLCJpYXQiOjE3MTg1NjU0MTUuODE1MzgzOSwibmJmIjoxNzE4NTY1NDE1LjgxNTM4OCwiZXhwIjoyNjY1MjUzODE1LjgwOTkwODksInN1YiI6IjEzMDkyNSIsInNjb3BlcyI6W119.OYTpCEjaa5Rzmdy2rHLpnGKBrV62Cg_Se5P5UoV_t1sf-NzgG3NMwcPFtOkh-ZVFKkfG7G4bsCl78KjiC8Qnmxd7TXRad_XoTaSVDFqMZlYMLlbSjjNw2lqo_O3UP-SMi-Gei6f9qc3Zs09uqEAnb1v7f2-qxu4YGAcsOEjHtYTURHJY6ZeRCrewZpI_6fGrQwdNqXSc_kNvO6ygIGOrK2pMJGm-WCiWzfKAdLg0L8gWlemLNeJumoe38XbYMnJ2upBzc-SGdsPf33_yvWmR15wBqpqqoO0b57KoLpzzppFBBQgJlqNjUOUs8MFlMVlbK1DVx8PdfvU1R--nVgQm8gWlV0IvaIcDa9Yqrz0IblrCco7T5adIM9tPSuRBdetD6dhqpGZEzUaqjO1f0AVQc3Vs7HsGsLGG2_D11Wwpl8texMTJpHCI6tV4fc5msi7kRdwBJ7PgsYkkJKVQV2Q1-Whk5xHvFZyiTYKkR_eHrNshCgL-n5FFqttbkZ_xP3q9qMsl93UVWCwE5zi-SnyJn2cmXKWAfGRsbSvge-UWlEduz_yGdfhSKjjhLfnkjZDmZANlY0_ylEnAUMwAy7oEFyrxf92PFsNzzXGfmVtowbhT1WOpltpZOeOFqS-lUm_A1UXE__OiKc5JeS8zjf2wxlZ1x9TKaFn5yHBJUwht8KA",
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
