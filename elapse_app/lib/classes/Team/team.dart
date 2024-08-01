import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';

import 'dart:convert';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Team {
  int id;
  String? teamName;
  String? teamNumber;
  String? organization;
  Location? location;
  String? grade;
  TeamStats? tournamentStats;

  Team(
      {required this.id,
      required this.teamName,
      required this.teamNumber,
      required this.organization,
      required this.location,
      required this.grade,
      this.tournamentStats});

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json["id"],
      teamName: json["team_name"],
      teamNumber: json["number"],
      organization: json["organization"],
      location: Location(
          city: (json["location"] as Map)["city"],
          region: (json["location"] as Map)["region"],
          address1: (json["location"] as Map)["address_1"],
          address2: (json["location"] as Map)["address_2"],
          country: (json["location"] as Map)["country"]),
      grade: json["grade"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "team_name": teamName,
      "number": teamNumber,
      "organization": organization,
      "location": location?.toJson(),
      "grade": grade,
    };
  }
}

Team loadTeam(team) {
  return Team(
    id: team["id"],
    teamName: team["team_name"],
    teamNumber: team["number"],
    organization: team["organization"],
    location: loadLocation(team["location"]),
    grade: team["grade"],
  );
}

Future<List<Team>> getTeams(int tournamentID) async {
  List<Team> teams = [];
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$tournamentID/teams?per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"];
    teams = parsed.map<Team>((json) => Team.fromJson(json)).toList();
    // print("finished getting teams");
  } else {
    throw Exception("Failed to load teams");
  }
  int lastPage = jsonDecode(response.body)["meta"]["last_page"];
  if (lastPage > 1) {
    // Fetch remaining pages in parallel
    List<Future<void>> pageFutures = [];
    for (int page = 2; page <= lastPage; page++) {
      pageFutures.add(_fetchAdditionalTeams(tournamentID, page, teams));
    }
    await Future.wait(pageFutures);
  }
  return teams;
}

Future<void> _fetchAdditionalTeams(
    int tournamentID, int page, List<Team> teams) async {
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$tournamentID/teams?page=$page&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    teams.addAll(parsed.map<Team>((json) => Team.fromJson(json)).toList());
  } else {
    throw Exception("Failed to load schedule");
  }
}

Future<Team> fetchTeam(int teamId) async {
  // Fetch team data
  final response = await http.get(
    Uri.parse("https://www.robotevents.com/api/v2/teams/$teamId"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  final parsed = (jsonDecode(response.body));
  final parsedLocation = parsed["location"];
  String teamName = parsed["team_name"];
  String teamNumber = parsed["number"];
  String organization = parsed["organization"];
  String grade = parsed["grade"];
  Location location = Location(
      address1: parsedLocation["address_1"],
      address2: parsedLocation["address_2"],
      city: parsedLocation["city"],
      region: parsedLocation["region"],
      country: parsedLocation["country"]);

  return Team(
    id: teamId,
    teamName: teamName,
    teamNumber: teamNumber,
    organization: organization,
    location: location,
    grade: grade,
  );
}
