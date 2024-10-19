import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';

import 'dart:convert';

import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:elapse_app/main.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Tournament {
  int id;

  int seasonID;
  String name;
  String sku;

  Location location;

  DateTime startDate;
  DateTime? endDate;

  List<Division> divisions;
  List<Team> teams;

  Map<int, TournamentSkills>? tournamentSkills;
  List<Award> awards;

  Tournament({
    required this.id,
    required this.name,
    required this.sku,
    required this.seasonID,
    required this.location,
    required this.startDate,
    required this.divisions,
    required this.teams,
    required this.awards,
    this.endDate,
    this.tournamentSkills,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "sku": sku,
      "seasonID": seasonID,
      "location": location.toJson(),
      "startDate": startDate.toIso8601String(),
      "endDate": endDate?.toIso8601String(),
      "divisions": divisions.map((e) => e.toJson()).toList(),
      "teams": teams.map((e) => e.toJson()).toList(),
      "awards": awards.map((e) => e.toJson()).toList(),
      "tournamentSkills": tournamentSkills?.map((key, value) {
        return MapEntry(key.toString(), value.toJson());
      })
    };
  }
}

Future<void> updateTournament(Tournament tournament) async {
  List<Future> tournamentFutures = [];

  tournamentFutures.add(getTournamentAwards(tournament.id).then((awards) {
    tournament.awards = awards;
  }));

  tournamentFutures.add(getSkillsRankings(tournament.id, Future.value(tournament.teams)).then((skills) {
    tournament.tournamentSkills = skills;
  }));

  for (Division division in tournament.divisions) {
    tournamentFutures.add(calcEventStats(tournament.id, division.id).then((teamStats) {
      division.teamStats = teamStats[1];
      division.games = teamStats[0];
    }));
  }

  await Future.wait(tournamentFutures);
}

Tournament loadTournament(json) {
  List<Division> divisions = [];
  final tournament = jsonDecode(json);
  for (var a in tournament["divisions"]) {
    divisions.add(loadDivision(a));
  }

  List<Team> teams = [];
  for (var a in tournament["teams"]) {
    teams.add(loadTeam(a));
  }

  List<Award> awards = [];
  for (var a in tournament["awards"]) {
    awards.add(loadAward(a));
  }

  Map<int, TournamentSkills>? tournamentSkills;
  if (tournament["tournamentSkills"] != null) {
    Map<String, dynamic> stringedSkills = tournament["tournamentSkills"];
    tournamentSkills = stringedSkills.map((key, value) {
      return MapEntry(int.parse(key), loadSkills(value));
    });
  }

  return Tournament(
    id: tournament["id"],
    name: tournament["name"],
    sku: tournament["sku"],
    seasonID: tournament["seasonID"],
    location: loadLocation(tournament["location"]),
    startDate: DateTime.parse(tournament["startDate"]),
    endDate: DateTime.tryParse(tournament["endDate"]),
    divisions: divisions,
    teams: teams,
    awards: awards,
    tournamentSkills: tournamentSkills,
  );
}

Future<Tournament> getTournamentDetails(int tournamentID) async {
  final response = await http.get(
    Uri.parse("https://www.robotevents.com/api/v2/events/$tournamentID"),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  try {
    final parsed = jsonDecode(response.body);

    List<Division> divisions = await Future.wait(parsed["divisions"].map<Future<Division>>((division) async {
      Division returnDivision = Division(
        id: division["id"],
        name: division["name"],
        order: division["order"],
      );
      List<Future<void>> divisionDetails = [];
      divisionDetails.add(calcEventStats(tournamentID, division["id"]).then((teamStats) {
        returnDivision.teamStats = teamStats[1];
        returnDivision.games = teamStats[0];
      }));

      await Future.wait(divisionDetails);
      return returnDivision;
    }).toList());

    Future<List<Team>> futureTeams = getTeams(tournamentID);
    Map<int, TournamentSkills> skills = await getSkillsRankings(tournamentID, futureTeams);

    List<Team> teams = await futureTeams;

    List<Award> awards = await getTournamentAwards(tournamentID);

    return Tournament(
      id: tournamentID,
      name: parsed["name"],
      seasonID: parsed["season"]["id"],
      sku: parsed["sku"],
      location: Location(
        venue: parsed["location"]["venue"],
        city: parsed["location"]["city"],
        region: parsed["location"]["region"],
        country: parsed["location"]["country"],
        address1: parsed["location"]["address_1"],
        address2: parsed["location"]["address_2"],
        postalCode: parsed["location"]["postcode"],
      ),
      startDate: DateTime.parse(parsed["start"]),
      endDate: DateTime.parse(parsed["end"]),
      teams: teams,
      divisions: divisions,
      tournamentSkills: skills,
      awards: awards,
    );
  } catch (e) {
    throw (e);
  }
}

Future<Tournament> TMTournamentDetails(int tournamentID, {bool forceRefresh = false}) async {
  Tournament tournament;
  if (prefs.getString("TMSavedTournament") == null) {
    tournament = await getTournamentDetails(tournamentID);
    prefs.setString("TMSavedTournament", jsonEncode(tournament.toJson()));
    print("Getting new tournament");
    return tournament;
  } else {
    tournament = loadTournament(prefs.getString("TMSavedTournament")!);
    print("Getting cached tournament");

    DateTime? updateTime = DateTime.tryParse(prefs.getString("updateTime") ?? "");

    if (updateTime == null || DateTime.now().isAfter(updateTime) || forceRefresh) {
      await updateTournament(tournament);
      prefs.setString("updateTime", DateTime.now().add(const Duration(seconds: 30)).toIso8601String());
      // Update every minute
    }

    prefs.setString("TMSavedTournament", jsonEncode(tournament.toJson()));
    prefs.setString("recently-opened-tournament", jsonEncode(tournament.toJson()));
    return tournament;
  }
}

bool hasCachedTMTournamentDetails() {
  DateTime? updateTime = DateTime.tryParse(prefs.getString("updateTime") ?? "");
  return prefs.getString("TMSavedTournament") != null && updateTime != null && DateTime.now().isBefore(updateTime);
}
