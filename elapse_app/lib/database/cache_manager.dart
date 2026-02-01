import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/database/tournament_repository.dart';
import 'package:flutter/foundation.dart';

/// Result of a tournament fetch operation.
/// Always contains information about the data source and any errors.
class TournamentResult {
  final Tournament? tournament;
  final DataSource source;
  final List<TournamentError> errors;

  TournamentResult({
    this.tournament,
    required this.source,
    this.errors = const [],
  });

  bool get hasData => tournament != null;
  bool get isStale => source == DataSource.staleCache;
  bool get hasErrors => errors.isNotEmpty;
}

/// Where the tournament data came from.
enum DataSource {
  api,        // Fresh from RobotEvents API
  cache,      // Valid cached data from SQLite
  staleCache, // Expired cache (API failed, showing old data)
  none,       // No data available
}

/// Error that occurred during tournament fetch.
class TournamentError {
  final String message;
  final dynamic originalError;
  final DateTime timestamp;

  TournamentError(this.message, [this.originalError])
      : timestamp = DateTime.now();

  @override
  String toString() => 'TournamentError: $message';
}

/// High-level caching manager for tournament data.
/// Provides a simple API that handles all caching logic internally.
///
/// Priority: Uptime > Speed
/// - Never crashes on malformed data
/// - Always returns something (fresh or stale) when possible
/// - Gracefully degrades on API failures
class CacheManager {
  final TournamentRepository _repo;

  static final CacheManager _instance = CacheManager._internal(TournamentRepository());

  /// In-memory cache of the last loaded tournament for sync access.
  /// This replaces the old SharedPreferences "recently-opened-tournament" pattern.
  static Tournament? _lastLoadedTournament;

  factory CacheManager() => _instance;

  CacheManager._internal(this._repo);

  /// Returns the last loaded tournament synchronously.
  /// Returns null if no tournament has been loaded yet.
  /// Use this for screens that need sync access (replaces SharedPreferences reads).
  static Tournament? get lastLoadedTournament => _lastLoadedTournament;

  /// Sets the last loaded tournament (called by TMTournamentDetails).
  static void setLastLoadedTournament(Tournament tournament) {
    _lastLoadedTournament = tournament;
  }

  /// Clears the in-memory cache (call when exiting tournament mode).
  static void clearLastLoadedTournament() {
    _lastLoadedTournament = null;
  }

  /// Gets tournament with caching logic.
  ///
  /// This is the main entry point - replaces the old SharedPreferences caching.
  ///
  /// Flow:
  /// 1. Check cache validity (unless forceRefresh)
  /// 2. If valid cache, return cached data
  /// 3. If no valid cache or forceRefresh, fetch from API
  /// 4. Cache the fresh data
  /// 5. If API fails, try to return stale cache as fallback
  /// 6. Only fail if no data available at all
  Future<TournamentResult> getTournamentWithCache(
    int tournamentId, {
    bool forceRefresh = false,
  }) async {
    // 1. Check cache first (unless force refresh)
    if (!forceRefresh) {
      final isValid = await _repo.isCacheValid(tournamentId);
      if (isValid) {
        final cached = await _repo.getCachedTournament(tournamentId);
        if (cached != null) {
          if (kDebugMode) print('CacheManager: Returning valid cached tournament $tournamentId');
          return TournamentResult(
            tournament: cached,
            source: DataSource.cache,
          );
        }
      }
    }

    // 2. Try to fetch fresh data from API
    try {
      if (kDebugMode) print('CacheManager: Fetching tournament $tournamentId from API');
      final tournament = await getTournamentDetails(tournamentId);

      // 3. Cache it (don't fail if caching fails)
      try {
        final result = await _repo.cacheTournament(tournament);
        if (kDebugMode) {
          if (result.errors.isNotEmpty) {
            print('CacheManager: Caching had ${result.errors.length} errors: ${result.errors}');
          } else {
            print('CacheManager: Successfully cached tournament $tournamentId');
          }
        }
      } catch (e) {
        if (kDebugMode) print('CacheManager: Failed to cache tournament: $e');
        // Continue - we still have the fresh data
      }

      return TournamentResult(
        tournament: tournament,
        source: DataSource.api,
      );

    } catch (apiError) {
      // 4. API failed - try stale cache as fallback
      if (kDebugMode) {
        print('CacheManager: API failed for tournament $tournamentId: $apiError');
        print('CacheManager: Trying stale cache as fallback');
      }

      final stale = await _repo.getCachedTournament(tournamentId);
      if (stale != null) {
        if (kDebugMode) print('CacheManager: Returning stale cached data');
        return TournamentResult(
          tournament: stale,
          source: DataSource.staleCache,
          errors: [TournamentError('API failed, showing cached data', apiError)],
        );
      }

      // 5. No cache available - this is the only case we actually fail
      if (kDebugMode) print('CacheManager: No cached data available, returning null');
      return TournamentResult(
        tournament: null,
        source: DataSource.none,
        errors: [TournamentError('No data available', apiError)],
      );
    }
  }

  /// Updates a tournament's dynamic data (awards, skills, stats) without full reload.
  /// Used for periodic updates during tournament mode.
  ///
  /// Similar to the old updateTournament() function but with SQLite caching.
  Future<TournamentResult> updateTournamentData(Tournament tournament) async {
    final errors = <TournamentError>[];

    try {
      // Update awards
      try {
        final awards = await getTournamentAwards(tournament.id);
        tournament.awards = awards;
      } catch (e) {
        errors.add(TournamentError('Failed to update awards', e));
      }

      // Update skills
      try {
        final skills = await getSkillsRankings(tournament.id, Future.value(tournament.teams));
        tournament.tournamentSkills = skills;
      } catch (e) {
        errors.add(TournamentError('Failed to update skills', e));
      }

      // Update each division's stats and games
      for (final division in tournament.divisions) {
        try {
          final teamStats = await calcEventStats(tournament.id, division.id);
          division.games = teamStats[0];
          if (teamStats.length > 1) {
            division.teamStats = teamStats[1];
          }
        } catch (e) {
          errors.add(TournamentError('Failed to update division ${division.id}', e));
        }
      }

      // Cache the updated tournament
      try {
        await _repo.cacheTournament(tournament);
      } catch (e) {
        errors.add(TournamentError('Failed to cache updated tournament', e));
      }

      return TournamentResult(
        tournament: tournament,
        source: DataSource.api,
        errors: errors,
      );

    } catch (e) {
      errors.add(TournamentError('Update failed', e));
      return TournamentResult(
        tournament: tournament, // Return original even if update failed
        source: DataSource.staleCache,
        errors: errors,
      );
    }
  }

  /// Checks if we have a valid (non-expired) cached tournament.
  Future<bool> hasCachedTournament(int tournamentId) async {
    return await _repo.isCacheValid(tournamentId);
  }

  /// Checks if we have any cached tournament data (even if expired).
  Future<bool> hasAnyCachedTournament(int tournamentId) async {
    return await _repo.tournamentExists(tournamentId);
  }

  /// Invalidates cached tournament data.
  Future<void> invalidateTournament(int tournamentId) async {
    await _repo.invalidateCache(tournamentId);
  }

  /// Updates cache expiry without re-fetching data.
  Future<void> extendCacheExpiry(int tournamentId, Duration duration) async {
    await _repo.updateCacheExpiry(tournamentId, duration);
  }
}
