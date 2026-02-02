import 'package:sqflite/sqflite.dart';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/classes/Filters/gradeLevel.dart';

import 'database_helper.dart';
import 'validators.dart';

class TournamentRepository {
  final DatabaseHelper _dbHelper;

  TournamentRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper();

  /// Saves a complete tournament to SQLite with validation.
  /// Returns IngestionResult with any errors encountered.
  /// Priority: Uptime > Speed - continues on individual failures.
  Future<IngestionResult<void>> cacheTournament(Tournament tournament) async {
    final errors = <IngestionError>[];

    try {
      final db = await _dbHelper.database;

      await db.transaction((txn) async {
        // 1. Delete existing tournament data (cascade deletes related data)
        await txn.delete('tournaments', where: 'id = ?', whereArgs: [tournament.id]);

        // 2. Validate and save tournament metadata
        try {
          final validated = TournamentValidator.validate(tournament.toJson());
          validated['last_updated'] = DateTime.now().toIso8601String();
          validated['cache_expiry'] = DateTime.now().add(const Duration(seconds: 30)).toIso8601String();

          await txn.insert('tournaments', validated, conflictAlgorithm: ConflictAlgorithm.replace);
        } catch (e) {
          errors.add(IngestionError(
            field: 'tournament',
            message: e.toString(),
            rawValue: tournament.id,
          ));
          rethrow; // Tournament is required - can't continue without it
        }

        // 3. Save divisions and their data
        for (final division in tournament.divisions) {
          try {
            await _saveDivision(txn, tournament.id, division, errors);
          } catch (e) {
            errors.add(IngestionError(
              field: 'division',
              message: e.toString(),
              rawValue: division.id,
            ));
            // Continue with other divisions
          }
        }

        // 4. Save teams
        for (final team in tournament.teams) {
          try {
            await _saveTeam(txn, tournament.id, team);
          } catch (e) {
            errors.add(IngestionError(
              field: 'team',
              message: e.toString(),
              rawValue: team.id,
            ));
          }
        }

        // 5. Save tournament skills
        if (tournament.tournamentSkills != null) {
          for (final entry in tournament.tournamentSkills!.entries) {
            try {
              await _saveSkills(txn, tournament.id, entry.key, entry.value);
            } catch (e) {
              errors.add(IngestionError(
                field: 'skills',
                message: e.toString(),
                rawValue: entry.key,
              ));
            }
          }
        }

        // 6. Save awards
        for (final award in tournament.awards) {
          try {
            await _saveAward(txn, tournament.id, award);
          } catch (e) {
            errors.add(IngestionError(
              field: 'award',
              message: e.toString(),
              rawValue: award.name,
            ));
          }
        }
      });
    } catch (e) {
      errors.add(IngestionError(
        field: 'transaction',
        message: e.toString(),
      ));
    }

    return IngestionResult(
      data: null,
      errors: errors,
      partial: errors.isNotEmpty,
    );
  }

  Future<void> _saveDivision(Transaction txn, int tournamentId, Division division, List<IngestionError> errors) async {
    // Save division
    await txn.insert('divisions', {
      'id': division.id,
      'tournament_id': tournamentId,
      'name': division.name,
      'order_num': division.order,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Save games
    if (division.games != null) {
      for (final game in division.games!) {
        try {
          await _saveGame(txn, division.id, game);
        } catch (e) {
          errors.add(IngestionError(
            field: 'game',
            message: e.toString(),
            rawValue: game.gameName,
          ));
        }
      }
    }

    // Save team stats
    if (division.teamStats != null) {
      for (final entry in division.teamStats!.entries) {
        try {
          await _saveTeamStats(txn, division.id, entry.key, entry.value);
        } catch (e) {
          errors.add(IngestionError(
            field: 'team_stats',
            message: e.toString(),
            rawValue: entry.key,
          ));
        }
      }
    }
  }

  Future<void> _saveGame(Transaction txn, int divisionId, Game game) async {
    // Insert the game
    final gameId = await txn.insert('games', {
      'division_id': divisionId,
      'round_num': game.roundNum,
      'game_num': game.gameNum,
      'instance': game.instance,
      'game_name': game.gameName,
      'field_name': game.fieldName,
      'scheduled_time': game.scheduledTime?.toIso8601String(),
      'started_time': game.startedTime?.toIso8601String(),
      'adjusted_time': game.adjustedTime?.toIso8601String(),
      'red_score': game.redScore,
      'blue_score': game.blueScore,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Save red alliance
    if (game.redAlliancePreview != null) {
      for (int i = 0; i < game.redAlliancePreview!.length; i++) {
        final team = game.redAlliancePreview![i];
        await txn.insert('game_alliances', {
          'game_id': gameId,
          'alliance': 'red',
          'team_id': team.teamID,
          'team_number': team.teamNumber,
          'position': i,
        });
      }
    }

    // Save blue alliance
    if (game.blueAlliancePreview != null) {
      for (int i = 0; i < game.blueAlliancePreview!.length; i++) {
        final team = game.blueAlliancePreview![i];
        await txn.insert('game_alliances', {
          'game_id': gameId,
          'alliance': 'blue',
          'team_id': team.teamID,
          'team_number': team.teamNumber,
          'position': i,
        });
      }
    }
  }

  Future<void> _saveTeam(Transaction txn, int tournamentId, Team team) async {
    await txn.insert('teams', {
      'id': team.id,
      'tournament_id': tournamentId,
      'team_number': team.teamNumber ?? '',
      'team_name': team.teamName,
      'organization': team.organization,
      'grade': team.grade?.name,
      'city': team.location?.city,
      'region': team.location?.region,
      'country': team.location?.country,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _saveTeamStats(Transaction txn, int divisionId, int teamId, TeamStats stats) async {
    await txn.insert('team_stats', {
      'division_id': divisionId,
      'team_id': teamId,
      'rank': stats.rank,
      'wins': stats.wins,
      'losses': stats.losses,
      'ties': stats.ties,
      'total_matches': stats.totalMatches,
      'wp': stats.wp,
      'ap': stats.ap,
      'sp': stats.sp,
      'awp': stats.awp,
      'awp_rate': stats.awpRate,
      'opr': stats.opr,
      'dpr': stats.dpr,
      'ccwm': stats.ccwm,
      'high_score': stats.highScore,
      'avg_score': stats.avgScore,
      'total_score': stats.totalScore,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _saveSkills(Transaction txn, int tournamentId, int teamId, TournamentSkills skills) async {
    await txn.insert('tournament_skills', {
      'tournament_id': tournamentId,
      'team_id': teamId,
      'rank': skills.rank,
      'score': skills.score,
      'auton_score': skills.autonScore,
      'auton_attempts': skills.autonAttempts,
      'driver_score': skills.driverScore,
      'driver_attempts': skills.driverAttempts,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _saveAward(Transaction txn, int tournamentId, Award award) async {
    final awardId = await txn.insert('awards', {
      'tournament_id': tournamentId,
      'name': award.name,
      'tournament_name': award.tournamentName,
    });

    // Save qualifications
    for (final qual in award.qualifications) {
      await txn.insert('award_qualifications', {
        'award_id': awardId,
        'qualification': qual,
      });
    }

    // Save team winners
    if (award.teamWinners != null) {
      for (final team in award.teamWinners!) {
        await txn.insert('award_team_winners', {
          'award_id': awardId,
          'team_id': team.teamID,
          'team_number': team.teamNumber,
        });
      }
    }

    // Save individual winners
    if (award.individualWinners != null) {
      for (final name in award.individualWinners!) {
        await txn.insert('award_individual_winners', {
          'award_id': awardId,
          'winner_name': name,
        });
      }
    }
  }

  /// Loads a complete tournament from SQLite.
  /// Returns null if not found. Never throws - returns null on any error.
  ///
  /// Uses batch queries to avoid N+1 problem - loads all related data in ~10 queries
  /// instead of O(divisions + games + awards) queries.
  Future<Tournament?> getCachedTournament(int tournamentId) async {
    try {
      final db = await _dbHelper.database;

      // Get tournament
      final tournamentRows = await db.query(
        'tournaments',
        where: 'id = ?',
        whereArgs: [tournamentId],
      );

      if (tournamentRows.isEmpty) return null;

      final row = tournamentRows.first;

      // Load all top-level related data in parallel (4 queries)
      final topLevelResults = await Future.wait([
        db.query('divisions', where: 'tournament_id = ?', whereArgs: [tournamentId], orderBy: 'order_num'),
        db.query('teams', where: 'tournament_id = ?', whereArgs: [tournamentId]),
        db.query('tournament_skills', where: 'tournament_id = ?', whereArgs: [tournamentId]),
        db.query('awards', where: 'tournament_id = ?', whereArgs: [tournamentId]),
      ]);

      final divisionRows = topLevelResults[0];
      final teamRows = topLevelResults[1];
      final skillsRows = topLevelResults[2];
      final awardRows = topLevelResults[3];

      // Get IDs for batch loading
      final divisionIds = divisionRows.map((r) => (r['id'] as num).toInt()).toList();
      final awardIds = awardRows.map((r) => (r['id'] as num).toInt()).toList();

      // Batch load division children (games, stats) and award children (3 + 3 = 6 queries)
      final childResults = await Future.wait([
        // Division children
        divisionIds.isEmpty ? Future.value(<Map<String, dynamic>>[]) :
          db.query('games', where: 'division_id IN (${divisionIds.join(",")})', orderBy: 'division_id, round_num, game_num, instance'),
        divisionIds.isEmpty ? Future.value(<Map<String, dynamic>>[]) :
          db.query('team_stats', where: 'division_id IN (${divisionIds.join(",")})'),
        // Award children
        awardIds.isEmpty ? Future.value(<Map<String, dynamic>>[]) :
          db.query('award_qualifications', where: 'award_id IN (${awardIds.join(",")})'),
        awardIds.isEmpty ? Future.value(<Map<String, dynamic>>[]) :
          db.query('award_team_winners', where: 'award_id IN (${awardIds.join(",")})'),
        awardIds.isEmpty ? Future.value(<Map<String, dynamic>>[]) :
          db.query('award_individual_winners', where: 'award_id IN (${awardIds.join(",")})'),
      ]);

      final allGameRows = childResults[0];
      final allStatsRows = childResults[1];
      final allQualRows = childResults[2];
      final allTeamWinnerRows = childResults[3];
      final allIndividualWinnerRows = childResults[4];

      // Get game IDs for alliance batch load (1 query)
      final gameIds = allGameRows.map((r) => (r['id'] as num).toInt()).toList();
      final allAllianceRows = gameIds.isEmpty ? <Map<String, dynamic>>[] :
        await db.query('game_alliances', where: 'game_id IN (${gameIds.join(",")})', orderBy: 'game_id, position');

      // Group data by parent ID for efficient lookup
      final gamesByDivision = _groupBy(allGameRows, 'division_id');
      final statsByDivision = _groupBy(allStatsRows, 'division_id');
      final alliancesByGame = _groupBy(allAllianceRows, 'game_id');
      final qualsByAward = _groupBy(allQualRows, 'award_id');
      final teamWinnersByAward = _groupBy(allTeamWinnerRows, 'award_id');
      final individualWinnersByAward = _groupBy(allIndividualWinnerRows, 'award_id');

      // Build divisions with their games and stats
      final divisions = _buildDivisions(divisionRows, gamesByDivision, statsByDivision, alliancesByGame);

      // Build teams
      final teams = _loadTeams(teamRows);

      // Build skills map
      final tournamentSkills = _loadSkillsMap(skillsRows);

      // Build awards
      final awards = _buildAwards(awardRows, qualsByAward, teamWinnersByAward, individualWinnersByAward);

      return Tournament(
        id: (row['id'] as num).toInt(),
        name: row['name'] as String? ?? '',
        sku: row['sku'] as String? ?? '',
        seasonID: (row['season_id'] as num?)?.toInt() ?? 0,
        location: Location(
          venue: row['venue'] as String?,
          city: row['city'] as String?,
          region: row['region'] as String?,
          country: row['country'] as String?,
          address1: row['address1'] as String?,
          address2: row['address2'] as String?,
          postalCode: row['postal_code'] as String?,
        ),
        startDate: DateTime.tryParse(row['start_date'] as String? ?? '') ?? DateTime.now(),
        endDate: row['end_date'] != null ? DateTime.tryParse(row['end_date'] as String) : null,
        divisions: divisions,
        teams: teams,
        tournamentSkills: tournamentSkills.isNotEmpty ? tournamentSkills : null,
        awards: awards,
      );
    } catch (e) {
      print('Failed to load cached tournament $tournamentId: $e');
      return null;
    }
  }

  /// Groups rows by a key field for O(1) lookup.
  Map<int, List<Map<String, dynamic>>> _groupBy(List<Map<String, dynamic>> rows, String keyField) {
    final map = <int, List<Map<String, dynamic>>>{};
    for (final row in rows) {
      final key = (row[keyField] as num).toInt();
      map.putIfAbsent(key, () => []).add(row);
    }
    return map;
  }

  /// Builds divisions from pre-loaded data (no additional queries).
  List<Division> _buildDivisions(
    List<Map<String, dynamic>> divisionRows,
    Map<int, List<Map<String, dynamic>>> gamesByDivision,
    Map<int, List<Map<String, dynamic>>> statsByDivision,
    Map<int, List<Map<String, dynamic>>> alliancesByGame,
  ) {
    return divisionRows.map((row) {
      final divisionId = (row['id'] as num).toInt();
      final gameRows = gamesByDivision[divisionId] ?? [];
      final statsRows = statsByDivision[divisionId] ?? [];

      final games = _buildGames(gameRows, alliancesByGame, divisionId);
      final teamStats = _loadTeamStatsMap(statsRows);

      return Division(
        id: divisionId,
        name: row['name'] as String? ?? '',
        order: (row['order_num'] as num?)?.toInt() ?? 0,
        games: games.isNotEmpty ? games : null,
        teamStats: teamStats.isNotEmpty ? teamStats : null,
      );
    }).toList();
  }

  /// Builds games from pre-loaded data (no additional queries).
  List<Game> _buildGames(
    List<Map<String, dynamic>> gameRows,
    Map<int, List<Map<String, dynamic>>> alliancesByGame,
    int divisionId,
  ) {
    return gameRows.map((row) {
      final gameId = (row['id'] as num).toInt();
      final allianceRows = alliancesByGame[gameId] ?? [];

      final redAlliance = <TeamPreview>[];
      final blueAlliance = <TeamPreview>[];

      for (final a in allianceRows) {
        final preview = TeamPreview(
          teamID: (a['team_id'] as num?)?.toInt() ?? 0,
          teamNumber: a['team_number'] as String? ?? '',
        );
        if (a['alliance'] == 'red') {
          redAlliance.add(preview);
        } else {
          blueAlliance.add(preview);
        }
      }

      return Game(
        redAlliancePreview: redAlliance,
        blueAlliancePreview: blueAlliance,
        redScore: (row['red_score'] as num?)?.toInt(),
        blueScore: (row['blue_score'] as num?)?.toInt(),
        divisionId: divisionId,
        roundNum: row['round_num'] as num? ?? 0,
        gameNum: (row['game_num'] as num?)?.toInt() ?? 0,
        instance: (row['instance'] as num?)?.toInt() ?? 1,
        gameName: row['game_name'] as String? ?? '',
        fieldName: row['field_name'] as String?,
        scheduledTime: row['scheduled_time'] != null ? DateTime.tryParse(row['scheduled_time'] as String) : null,
        startedTime: row['started_time'] != null ? DateTime.tryParse(row['started_time'] as String) : null,
        adjustedTime: row['adjusted_time'] != null ? DateTime.tryParse(row['adjusted_time'] as String) : null,
      );
    }).toList();
  }

  List<Team> _loadTeams(List<Map<String, dynamic>> teamRows) {
    return teamRows.map((row) => Team(
      id: (row['id'] as num).toInt(),
      teamName: row['team_name'] as String?,
      teamNumber: row['team_number'] as String?,
      organization: row['organization'] as String?,
      location: Location(
        city: row['city'] as String?,
        region: row['region'] as String?,
        country: row['country'] as String?,
      ),
      grade: row['grade'] != null ? getGradeLevel(row['grade'] as String) : null,
    )).toList();
  }

  Map<int, TeamStats> _loadTeamStatsMap(List<Map<String, dynamic>> statsRows) {
    final map = <int, TeamStats>{};
    for (final row in statsRows) {
      final teamId = (row['team_id'] as num).toInt();
      map[teamId] = TeamStats()
        ..rank = (row['rank'] as num?)?.toInt() ?? 0
        ..wins = (row['wins'] as num?)?.toInt() ?? 0
        ..losses = (row['losses'] as num?)?.toInt() ?? 0
        ..ties = (row['ties'] as num?)?.toInt() ?? 0
        ..totalMatches = (row['total_matches'] as num?)?.toInt() ?? 0
        ..wp = (row['wp'] as num?)?.toInt() ?? 0
        ..ap = (row['ap'] as num?)?.toInt() ?? 0
        ..sp = (row['sp'] as num?)?.toInt() ?? 0
        ..awp = (row['awp'] as num?)?.toInt() ?? 0
        ..awpRate = (row['awp_rate'] as num?)?.toDouble() ?? 0.0
        ..opr = (row['opr'] as num?)?.toDouble() ?? 0.0
        ..dpr = (row['dpr'] as num?)?.toDouble() ?? 0.0
        ..ccwm = (row['ccwm'] as num?)?.toDouble() ?? 0.0
        ..highScore = (row['high_score'] as num?)?.toInt() ?? 0
        ..avgScore = (row['avg_score'] as num?)?.toDouble() ?? 0.0
        ..totalScore = (row['total_score'] as num?)?.toInt() ?? 0;
    }
    return map;
  }

  Map<int, TournamentSkills> _loadSkillsMap(List<Map<String, dynamic>> skillsRows) {
    final map = <int, TournamentSkills>{};
    for (final row in skillsRows) {
      final teamId = (row['team_id'] as num).toInt();
      map[teamId] = TournamentSkills()
        ..rank = (row['rank'] as num?)?.toInt() ?? 0
        ..score = (row['score'] as num?)?.toInt() ?? 0
        ..autonScore = (row['auton_score'] as num?)?.toInt() ?? 0
        ..autonAttempts = (row['auton_attempts'] as num?)?.toInt() ?? 0
        ..driverScore = (row['driver_score'] as num?)?.toInt() ?? 0
        ..driverAttempts = (row['driver_attempts'] as num?)?.toInt() ?? 0;
    }
    return map;
  }

  /// Builds awards from pre-loaded data (no additional queries).
  List<Award> _buildAwards(
    List<Map<String, dynamic>> awardRows,
    Map<int, List<Map<String, dynamic>>> qualsByAward,
    Map<int, List<Map<String, dynamic>>> teamWinnersByAward,
    Map<int, List<Map<String, dynamic>>> individualWinnersByAward,
  ) {
    return awardRows.map((row) {
      final awardId = (row['id'] as num).toInt();

      final qualifications = (qualsByAward[awardId] ?? [])
          .map((r) => r['qualification'] as String)
          .toList();
      final teamWinners = (teamWinnersByAward[awardId] ?? [])
          .map((r) => TeamPreview(
                teamID: (r['team_id'] as num?)?.toInt() ?? 0,
                teamNumber: r['team_number'] as String? ?? '',
              ))
          .toList();
      final individualWinners = (individualWinnersByAward[awardId] ?? [])
          .map((r) => r['winner_name'] as String)
          .toList();

      return Award(
        name: row['name'] as String? ?? '',
        qualifications: qualifications,
        tournamentName: row['tournament_name'] as String?,
        teamWinners: teamWinners.isNotEmpty ? teamWinners : null,
        individualWinners: individualWinners.isNotEmpty ? individualWinners : null,
      );
    }).toList();
  }

  /// Checks if the cached tournament is still valid (not expired).
  Future<bool> isCacheValid(int tournamentId) async {
    try {
      final db = await _dbHelper.database;
      final rows = await db.query(
        'tournaments',
        columns: ['cache_expiry'],
        where: 'id = ?',
        whereArgs: [tournamentId],
      );

      if (rows.isEmpty) return false;

      final expiry = DateTime.tryParse(rows.first['cache_expiry']?.toString() ?? '');
      if (expiry == null) return false;

      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }

  /// Checks if a tournament exists in the cache (regardless of expiry).
  Future<bool> tournamentExists(int tournamentId) async {
    try {
      final db = await _dbHelper.database;
      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM tournaments WHERE id = ?',
        [tournamentId],
      ));
      return (count ?? 0) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Updates the cache expiry time for a tournament.
  Future<void> updateCacheExpiry(int tournamentId, Duration duration) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'tournaments',
        {
          'cache_expiry': DateTime.now().add(duration).toIso8601String(),
          'last_updated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [tournamentId],
      );
    } catch (e) {
      print('Failed to update cache expiry: $e');
    }
  }

  /// Invalidates (deletes) a cached tournament.
  Future<void> invalidateCache(int tournamentId) async {
    await _dbHelper.deleteTournament(tournamentId);
  }
}
