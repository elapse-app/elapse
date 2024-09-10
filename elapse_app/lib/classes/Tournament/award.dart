import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Award {
  String name;
  List<String> qualifications;
  String? tournamentName;
  List<TeamPreview>? teamWinners;
  List<TeamPreview>? individualWinners;

  Award({
    required this.name,
    required this.qualifications,
    this.tournamentName,
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
      qualifications.add(parseQualification(a));
    }

    String awardName = "";
    List<String> splitName = json["title"].split(" ");
    for (int i = 0; i < splitName.length - 1; i++) {
      if (splitName[i] == "(VRC/VEXU/VAIRC)") {
        break;
      }
      awardName += "${splitName[i]} ";
    }

    return Award(
      name: awardName,
      qualifications: qualifications,
      tournamentName: json["event"]["name"],
      teamWinners: teamWinners,
      individualWinners: individualWinners,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "qualifications": qualifications,
      "tournamentName": tournamentName,
      "teamWinners": teamWinners?.map((e) => e.toJson()).toList(),
      "individualWinners": individualWinners?.map((e) => e.toJson()).toList(),
    };
  }
}

Award loadAward(award) {
  List<TeamPreview> teamWinners = [];
  for (var a in award["teamWinners"]) {
    teamWinners.add(loadTeamPreview(jsonEncode(a)));
  }

  List<TeamPreview> individualWinners = [];
  for (var a in award["individualWinners"]) {
    individualWinners.add(loadTeamPreview(jsonEncode(a)));
  }

  List<String> qualifications = [];
  for (var a in award["qualifications"]) {
    qualifications.add(parseQualification(a));
  }

  return Award(
    name: award["name"],
    qualifications: qualifications,
    tournamentName: award["tournamentName"],
    teamWinners: teamWinners,
    individualWinners: individualWinners,
  );
}

Future<List<Award>> getAwards(int teamID, int seasonID) async {
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/teams/$teamID/awards?season%5B%5D=$seasonID&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  final parsed = jsonDecode(response.body)["data"] as List;
  List<Award> awards =
      parsed.map<Award>((json) => Award.fromJson(json)).toList();

  return awards;
}

Future<List<Award>> getTournamentAwards(int tournamentID) async {
  final response = await http.get(
    Uri.parse("https://www.robotevents.com/api/v2/events/$tournamentID/awards"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  final parsed = jsonDecode(response.body)["data"] as List;
  List<Award> awards =
      parsed.map<Award>((json) => Award.fromJson(json)).toList();

  return awards;
}

String parseQualification(String qualification) {
  String parsed = "NQ";
  if (qualification == "World Championship") {
    parsed = "WC";
  }
  if (qualification == "Event Region Championship") {
    parsed = "RC";
  }
  return parsed;
}
