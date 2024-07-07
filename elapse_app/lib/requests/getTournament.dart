import 'dart:convert';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/requests/getTeams.dart';
import 'package:elapse_app/requests/token.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

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
      }).catchError((e) => print(e)));
      ;
      await Future.wait(divisionDetails);
      return returnDivision;
    }).toList());

    List<Team> teams = await getTeams(tournamentID);

    print(teams.length);
    return Tournament(
      id: tournamentID,
      name: parsed["name"],
      seasonID: parsed["season"]["id"],
      location: Location(venue: parsed["location"]["venue"]),
      startDate: DateTime.parse(parsed["start"]),
      endDate: DateTime.parse(parsed["end"]),
      teams: teams,
      divisions: divisions,
    );
  } catch (e) {
    throw (e);
  }
}
