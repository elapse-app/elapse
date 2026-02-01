import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/league_session.dart';
import 'package:flutter/foundation.dart';

import 'dart:convert';

import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/database/cache_manager.dart';
import 'package:elapse_app/database/tournament_repository.dart';
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

  List<LeagueSession>? sessions;

  /// Returns true if this is a league event with multiple sessions
  bool get isLeague => sessions != null && sessions!.isNotEmpty;

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
    this.sessions,
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
      }),
      "sessions": sessions?.map((s) => s.toJson()).toList(),
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

  print("PRINT tournament loading...");
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

  List<LeagueSession>? sessions;
  if (tournament["sessions"] != null) {
    sessions = (tournament["sessions"] as List)
        .map((s) => LeagueSession.fromJson(s))
        .toList();
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
    sessions: sessions,
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

    // DEBUG: Log API response structure for league session support
    if (kDebugMode) {
      debugPrint('=== API Response Debug (Event $tournamentID) ===');
      debugPrint('event_type: ${parsed['event_type']}');
      debugPrint('locations: ${parsed['locations'] != null ? jsonEncode(parsed['locations']) : 'null'}');
      debugPrint('=== End API Debug ===');
    }

    List<Division> divisions = await Future.wait(parsed["divisions"].map<Future<Division>>((division) async {
      Division returnDivision = Division(
        id: division["id"],
        name: division["name"],
        order: division["order"],
      );
      List<Future<void>> divisionDetails = [];
      divisionDetails.add(calcEventStats(tournamentID, division["id"]).then((teamStats) {
        if (teamStats.length > 1) {
          returnDivision.teamStats = teamStats[1];
        } else {
          returnDivision.teamStats = {};
        }
        returnDivision.games = teamStats[0];
      }));

      await Future.wait(divisionDetails);
      return returnDivision;
    }).toList());

    Future<List<Team>> futureTeams = getTeams(tournamentID);
    Map<int, TournamentSkills> skills = await getSkillsRankings(tournamentID, futureTeams);

    List<Team> teams = await futureTeams;

    List<Award> awards = await getTournamentAwards(tournamentID);

    // Parse sessions from locations Map (for leagues)
    List<LeagueSession>? sessions;
    if (parsed['locations'] != null &&
        parsed['locations'] is Map &&
        (parsed['locations'] as Map).isNotEmpty) {
      final locationsMap = parsed['locations'] as Map<String, dynamic>;
      sessions = locationsMap.entries
          .map((entry) => LeagueSession.fromMapEntry(entry.key, entry.value))
          .toList();
      // Sort sessions by date
      sessions.sort((a, b) => a.date.compareTo(b.date));
    }

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
      sessions: sessions,
    );
  } catch (e) {
    throw (e);
  }
}

/// Gets tournament details with SQLite caching.
///
/// Uses CacheManager for persistent storage with:
/// - 30-second cache expiry for fresh data
/// - Graceful degradation (returns stale cache if API fails)
/// - Never crashes on malformed data
Future<Tournament> TMTournamentDetails(int tournamentID, {bool forceRefresh = false}) async {
  final cacheManager = CacheManager();
  final result = await cacheManager.getTournamentWithCache(
    tournamentID,
    forceRefresh: forceRefresh,
  );

  if (result.hasData) {
    final tournament = result.tournament!;

    // Log data source for debugging (only in debug builds)
    if (kDebugMode) {
      if (result.isStale) {
        print("TMTournamentDetails: Using stale cache (API failed)");
      } else if (result.source == DataSource.cache) {
        print("TMTournamentDetails: Using valid cache");
      } else {
        print("TMTournamentDetails: Fresh data from API");
      }
    }

    return tournament;
  }

  // No data available - throw to maintain existing error behavior
  throw Exception("Failed to load tournament: ${result.errors.map((e) => e.message).join(', ')}");
}

/// Gets a tournament from SQLite cache by ID.
/// Returns null if not found or on any error.
/// This is the primary way to access tournament data - always reads from SQLite.
Future<Tournament?> getTournamentFromCache(int tournamentId) async {
  final repo = TournamentRepository();
  return await repo.getCachedTournament(tournamentId);
}

/// Clears the tournament cache for a specific tournament.
/// Call this when exiting tournament mode.
Future<void> invalidateTournamentCache(int tournamentId) async {
  final repo = TournamentRepository();
  await repo.invalidateCache(tournamentId);
}
