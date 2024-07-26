import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Award {
  String name;
  List<String> qualifications;
  TournamentPreview? tournament;
  List<TeamPreview>? teamWinners;
  List<TeamPreview>? individualWinners;

  Award({
    required this.name,
    required this.qualifications,
    this.tournament,
    this.teamWinners,
    this.individualWinners,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    List<TeamPreview> teamWinners = [];
    for (var a in json["teamWinners"]) {
      Map<String, dynamic> team = a["team"] as Map<String, dynamic>;
      teamWinners
          .add(TeamPreview(teamNumber: team["name"], teamID: team["id"]));
    }

    List<TeamPreview> individualWinners = [];
    for (var a in json["individualWinners"]) {
      Map<String, dynamic> team = a["team"] as Map<String, dynamic>;
      individualWinners
          .add(TeamPreview(teamNumber: team["name"], teamID: team["id"]));
    }

    List<String> qualifications = [];
    for (var a in json["qualifications"]) {
      qualifications.add(a);
    }

    String awardName = "";
    List<String> splitName = json["title"].split(" ");
    for (int i = 0; i < splitName.length; i++) {
      if (splitName[i] == "(VRC/VEXU/VAIRC)") {
        break;
      }
      awardName += splitName[i] + " ";
    }

    return Award(
      name: awardName,
      qualifications: qualifications,
      tournament: TournamentPreview(
        id: json["event"]["id"],
        name: json["event"]["name"],
      ),
      teamWinners: teamWinners,
      individualWinners: individualWinners,
    );
  }
}

Future<List<Award>> getAwards(int teamID, int seasonID) async {
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/teams/$teamID/awards?season%5B%5D=$seasonID&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  final parsed = jsonDecode(response.body)["data"] as List;
  List<Award> awards =
      parsed.map<Award>((json) => Award.fromJson(json)).toList();

  return awards;
}
