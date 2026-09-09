import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';

import 'dart:convert';

import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/extras/async_cache.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:elapse_app/main.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Tournament {
  final int id;

  final int seasonID;
  final String name;
  final String sku;

  final Location location;

  final DateTime startDate;
  final DateTime? endDate;

  final List<Division> divisions;
  final List<Team> teams;

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

  tournamentFutures.add(
      getSkillsRankings(tournament.id, Future.value(tournament.teams))
          .then((skills) {
    tournament.tournamentSkills = skills;
  }));

  for (Division division in tournament.divisions) {
    tournamentFutures
        .add(calcEventStats(tournament.id, division.id).then((teamStats) {
      division.teamStats = teamStats[1];
      division.games = teamStats[0];
    }));
  }

  await Future.wait(tournamentFutures);
}

Tournament loadTournament(String? json) {
  if (json == null || json.isEmpty) {
    throw const FormatException('Missing cached tournament.');
  }
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
    endDate: DateTime.tryParse(tournament["endDate"]?.toString() ?? ''),
    divisions: divisions,
    teams: teams,
    awards: awards,
    tournamentSkills: tournamentSkills,
  );
}

Future<Tournament> getTournamentDetails(int tournamentID) async {
  final response = await http.get(
    Uri.parse('https://events.vex.com/api/v2/events/$tournamentID'),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
      HttpHeaders.acceptHeader: 'application/json',
    },
  ).timeout(const Duration(seconds: 12));
  if (response.statusCode != 200) {
    throw StateError(
      'Tournament request failed (${response.statusCode})',
    );
  }

  final parsed = jsonDecode(response.body) as Map<String, dynamic>;
  final divisionsFuture = Future.wait(
    (parsed['divisions'] as List).map<Future<Division>>((division) async {
      final returnDivision = Division(
        id: division["id"],
        name: division["name"],
        order: division["order"],
      );
      final teamStats = await calcEventStats(tournamentID, division['id']);
      returnDivision.teamStats = teamStats.length > 1 ? teamStats[1] : {};
      returnDivision.games = teamStats[0];
      return returnDivision;
    }),
  );
  final teamsFuture = getTeams(tournamentID);
  final skillsFuture = getSkillsRankings(tournamentID, teamsFuture);
  final awardsFuture = getTournamentAwards(tournamentID);

  final divisions = await divisionsFuture;
  final teams = await teamsFuture;
  final skills = await skillsFuture;
  final awards = await awardsFuture;

  return Tournament(
    id: tournamentID,
    name: parsed['name'],
    seasonID: parsed['season']['id'],
    sku: parsed['sku'],
    location: Location(
      venue: parsed['location']['venue'],
      city: parsed['location']['city'],
      region: parsed['location']['region'],
      country: parsed['location']['country'],
      address1: parsed['location']['address_1'],
      address2: parsed['location']['address_2'],
      postalCode: parsed['location']['postcode'],
    ),
    startDate: DateTime.parse(parsed['start']),
    endDate: DateTime.tryParse(parsed['end']?.toString() ?? ''),
    teams: teams,
    divisions: divisions,
    tournamentSkills: skills,
    awards: awards,
  );
}

final _tournamentDetailsCache = AsyncCache<int, Tournament>(
  timeToLive: const Duration(seconds: 30),
);

Future<Tournament> TMTournamentDetails(
  int tournamentID, {
  bool forceRefresh = false,
}) {
  return _tournamentDetailsCache.get(
    tournamentID,
    () => _loadTMTournamentDetails(
      tournamentID,
      forceRefresh: forceRefresh,
    ),
    forceRefresh: forceRefresh,
  );
}

Future<Tournament> _loadTMTournamentDetails(
  int tournamentID, {
  required bool forceRefresh,
}) async {
  final savedTournament = prefs.getString('TMSavedTournament');
  Tournament? tournament;
  if (savedTournament != null && savedTournament.isNotEmpty) {
    try {
      final cached = loadTournament(savedTournament);
      if (cached.id == tournamentID) {
        tournament = cached;
      }
    } catch (_) {
      // Replace corrupt or outdated local data with a fresh API response.
    }
  }

  final updateTime = DateTime.tryParse(prefs.getString('updateTime') ?? '');
  if (tournament == null) {
    tournament = await getTournamentDetails(tournamentID);
  } else if (forceRefresh ||
      updateTime == null ||
      !updateTime.isAfter(DateTime.now())) {
    await updateTournament(tournament);
  }

  final encodedTournament = jsonEncode(tournament.toJson());
  await Future.wait([
    prefs.setString('TMSavedTournament', encodedTournament),
    prefs.setString('recently-opened-tournament', encodedTournament),
    prefs.setString(
      'updateTime',
      DateTime.now().add(const Duration(seconds: 30)).toIso8601String(),
    ),
  ]);
  return tournament;
}

bool hasCachedTMTournamentDetails() {
  DateTime? updateTime = DateTime.tryParse(prefs.getString("updateTime") ?? "");
  return prefs.getString("TMSavedTournament") != null &&
      updateTime != null &&
      DateTime.now().isBefore(updateTime);
}
