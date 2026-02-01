import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'dart:convert';

import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';

class Game {
  List<TeamPreview>? redAlliancePreview;
  List<TeamPreview>? blueAlliancePreview;

  int? redScore;
  int? blueScore;

  int divisionId;
  num roundNum;
  int gameNum;
  int instance;
  String gameName;

  String? fieldName;

  DateTime? scheduledTime;
  DateTime? startedTime;
  DateTime? adjustedTime;

  Game({
    this.redAlliancePreview,
    this.blueAlliancePreview,
    required this.divisionId,
    required this.gameNum,
    required this.roundNum,
    required this.gameName,
    required this.instance,
    this.fieldName,
    this.scheduledTime,
    this.startedTime,
    this.adjustedTime,
    this.redScore,
    this.blueScore,
  });

  factory Game.fromJson(Map<String, dynamic> json, int divisionId) {
    List<TeamPreview> redAlliancePreview = [];
    List<TeamPreview> blueAlliancePreview = [];
    int redScore = 0;

    int blueScore = 0;

    num roundNum = json["round"] == 6 ? 2.5 : json["round"];

    List<dynamic> alliances = json["alliances"];

    if (alliances.length >= 2) {
      if (alliances[0]["color"] == "red") {
        for (int i = 0; i < alliances[0]["teams"].length; i++) {
          redAlliancePreview.add(TeamPreview(
              teamID: alliances[0]["teams"][i]["team"]["id"],
              teamNumber: alliances[0]["teams"][i]["team"]["name"]));
        }
        redScore = alliances[0]["score"];
        for (int i = 0; i < alliances[1]["teams"].length; i++) {
          blueAlliancePreview.add(TeamPreview(
              teamID: alliances[1]["teams"][i]["team"]["id"],
              teamNumber: alliances[1]["teams"][i]["team"]["name"]));
        }
        blueScore = alliances[1]["score"];
      } else {
        for (int i = 0; i < alliances[1]["teams"].length; i++) {
          redAlliancePreview.add(TeamPreview(
              teamID: alliances[1]["teams"][i]["team"]["id"],
              teamNumber: alliances[1]["teams"][i]["team"]["name"]));
        }
        redScore = alliances[1]["score"];
        for (int i = 0; i < alliances[0]["teams"].length; i++) {
          blueAlliancePreview.add(TeamPreview(
              teamID: alliances[0]["teams"][i]["team"]["id"],
              teamNumber: alliances[0]["teams"][i]["team"]["name"]));
        }
        blueScore = alliances[0]["score"];
      }
    }

    String gameName = "";
    List<String> nameParts = (json["name"] ?? "").split(" ");
    String firstPart = nameParts.isNotEmpty ? nameParts[0] : "";
    firstPart = firstPart == "Qualifier" ? "Q" : firstPart;
    firstPart = firstPart == "Practice " ? "P" : firstPart;
    firstPart = firstPart == "Practice" ? "P" : firstPart;
    firstPart = firstPart == "Final" ? "F" : firstPart;
    String secondPart = nameParts.length > 1 ? nameParts[1] : "";

    secondPart = secondPart.split("-")[0];
    List<String> hashParts = secondPart.split("#");
    secondPart = hashParts.length > 1 ? hashParts[1] : secondPart;
    if (firstPart == "F") {
      secondPart = json["matchnum"].toString();
    }
    gameName = "$firstPart$secondPart";

    return Game(
      redAlliancePreview: redAlliancePreview,
      blueAlliancePreview: blueAlliancePreview,
      redScore: redScore,
      blueScore: blueScore,
      divisionId: divisionId,
      roundNum: roundNum,
      gameNum: json["matchnum"],
      instance: json["instance"],
      gameName: gameName,
      fieldName: json["field"],
      scheduledTime: DateTime.tryParse(json["scheduled"] ?? ""),
      startedTime: DateTime.tryParse(json["started"] ?? ""),
      adjustedTime: null,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> redAlliancePreviewStrings;
    List<Map<String, dynamic>> blueAlliancePreviewStrings;
    redAlliancePreviewStrings =
        this.redAlliancePreview!.map((team) => team.toJson()).toList();
    blueAlliancePreviewStrings =
        this.blueAlliancePreview!.map((team) => team.toJson()).toList();
    return {
      "redAlliancePreview": redAlliancePreviewStrings,
      "blueAlliancePreview": blueAlliancePreviewStrings,
      "redScore": redScore,
      "blueScore": blueScore,
      "divisionId": divisionId,
      "roundNum": roundNum,
      "gameNum": gameNum,
      "instance": instance,
      "gameName": gameName,
      "fieldName": fieldName,
      "scheduledTime": scheduledTime?.toIso8601String(),
      "startedTime": startedTime?.toIso8601String(),
      "adjustedTime": adjustedTime?.toIso8601String(),
    };
  }
}

Future<List<Game>>? getTournamentSchedule(
    int tournamentID, int divisionID) async {
  // Fetch data for each division in parallel
  final divisionMatches = await _fetchDivisionMatches(tournamentID, divisionID);

  // Sort and print the matches

  divisionMatches.sort((a, b) {
    int result = a.roundNum.compareTo(b.roundNum);
    if (result != 0) return result;

    result = a.gameNum.compareTo(b.gameNum);
    if (result != 0) return result;

    return a.instance.compareTo(b.instance);
  });

  return divisionMatches;
}

Future<List<Game>> _fetchDivisionMatches(int eventId, divisionID) async {
  List<Game> divisionMatches = [];
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionID/matches?per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    divisionMatches = parsed.map<Game>((json) => Game.fromJson(json, divisionID)).toList();
  } else {
    throw Exception("Failed to load schedule");
  }

  int lastPage = jsonDecode(response.body)["meta"]["last_page"];
  if (lastPage > 1) {
    // Fetch remaining pages in parallel
    List<Future<void>> pageFutures = [];
    for (int page = 2; page <= lastPage; page++) {
      pageFutures.add(
          _fetchAdditionalPage(eventId, divisionID, page, divisionMatches));
    }
    await Future.wait(pageFutures);
  }

  return divisionMatches;
}

Future<void> _fetchAdditionalPage(
    int eventId, int divisionId, int page, List<Game> divisionMatches) async {
  final response = await http.get(
    Uri.parse(
        "https://www.robotevents.com/api/v2/events/$eventId/divisions/$divisionId/matches?page=$page&per_page=250"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  if (response.statusCode == 200) {
    final parsed = jsonDecode(response.body)["data"] as List;
    divisionMatches
        .addAll(parsed.map<Game>((json) => Game.fromJson(json, divisionId)).toList());
  } else {
    throw Exception("Failed to load schedule");
  }
}

Game loadGame(game) {
  List<TeamPreview> redAlliancePreview =
      (game["redAlliancePreview"]).map<TeamPreview>((e) {
    return TeamPreview(teamNumber: e["teamNumber"], teamID: e["teamID"]);
  }).toList() as List<TeamPreview>;

  List<TeamPreview> blueAlliancePreview =
      game["blueAlliancePreview"].map<TeamPreview>((e) {
    return TeamPreview(teamNumber: e["teamNumber"], teamID: e["teamID"]);
  }).toList() as List<TeamPreview>;
  return Game(
    redAlliancePreview: redAlliancePreview,
    blueAlliancePreview: blueAlliancePreview,
    redScore: game["redScore"],
    blueScore: game["blueScore"],
    divisionId: game["divisionId"],
    roundNum: game["roundNum"],
    gameNum: game["gameNum"],
    instance: game["instance"],
    gameName: game["gameName"],
    fieldName: game["fieldName"],
    scheduledTime: DateTime.tryParse(game["scheduledTime"].toString()),
    startedTime: DateTime.tryParse(game["startedTime"].toString()),
    adjustedTime: DateTime.tryParse(game["adjustedTime"].toString()),
  );
}
