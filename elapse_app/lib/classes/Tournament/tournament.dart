import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';

import 'dart:convert';

import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/extras/token.dart';
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
}

Future<Tournament> getTournamentDetails(int tournamentID) async {
  final response = await http.get(
    Uri.parse("https://www.robotevents.com/api/v2/events/$tournamentID"),
    headers: {
      HttpHeaders.authorizationHeader: TOKEN,
    },
  );

  try {
    final parsed = jsonDecode(response.body);

    List<Division> divisions = await Future.wait(
        parsed["divisions"].map<Future<Division>>((division) async {
      Division returnDivision = Division(
        id: division["id"],
        name: division["name"],
        order: division["order"],
      );
      List<Future<void>> divisionDetails = [];
      divisionDetails
          .add(calcEventStats(tournamentID, division["id"]).then((teamStats) {
        returnDivision.teamStats = teamStats[1];
        returnDivision.games = teamStats[0];
      }));
      ;
      await Future.wait(divisionDetails);
      return returnDivision;
    }).toList());

    Future<List<Team>> futureTeams = getTeams(tournamentID);
    print("Getting Teams");
    Map<int, TournamentSkills> skills =
        await getSkillsRankings(tournamentID, futureTeams);
    print("Getting skills");

    List<Team> teams = await futureTeams;
    print("Got teams");

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
