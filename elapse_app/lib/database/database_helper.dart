import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'elapse_cache.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tournaments table
    await db.execute('''
      CREATE TABLE tournaments (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL DEFAULT '',
        sku TEXT NOT NULL DEFAULT '',
        season_id INTEGER NOT NULL DEFAULT 0,
        start_date TEXT NOT NULL DEFAULT '',
        end_date TEXT,
        venue TEXT,
        city TEXT,
        region TEXT,
        country TEXT,
        address1 TEXT,
        address2 TEXT,
        postal_code TEXT,
        last_updated TEXT NOT NULL DEFAULT '',
        cache_expiry TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Divisions table
    await db.execute('''
      CREATE TABLE divisions (
        id INTEGER PRIMARY KEY,
        tournament_id INTEGER NOT NULL,
        name TEXT NOT NULL DEFAULT '',
        order_num INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_divisions_tournament ON divisions(tournament_id)');

    // Teams table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY,
        tournament_id INTEGER NOT NULL,
        team_number TEXT NOT NULL DEFAULT '',
        team_name TEXT,
        organization TEXT,
        grade TEXT,
        city TEXT,
        region TEXT,
        country TEXT,
        FOREIGN KEY (tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_teams_tournament ON teams(tournament_id)');
    await db.execute('CREATE INDEX idx_teams_number ON teams(team_number)');

    // Games table
    await db.execute('''
      CREATE TABLE games (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        division_id INTEGER NOT NULL,
        round_num REAL NOT NULL DEFAULT 0,
        game_num INTEGER NOT NULL DEFAULT 0,
        instance INTEGER NOT NULL DEFAULT 1,
        game_name TEXT NOT NULL DEFAULT '',
        field_name TEXT,
        scheduled_time TEXT,
        started_time TEXT,
        adjusted_time TEXT,
        red_score INTEGER,
        blue_score INTEGER,
        FOREIGN KEY (division_id) REFERENCES divisions(id) ON DELETE CASCADE,
        UNIQUE(division_id, round_num, game_num, instance)
      )
    ''');
    await db.execute('CREATE INDEX idx_games_division ON games(division_id)');
    await db.execute('CREATE INDEX idx_games_round ON games(division_id, round_num)');

    // Game alliances table
    await db.execute('''
      CREATE TABLE game_alliances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        game_id INTEGER NOT NULL,
        alliance TEXT NOT NULL CHECK(alliance IN ('red', 'blue')),
        team_id INTEGER NOT NULL DEFAULT 0,
        team_number TEXT NOT NULL DEFAULT '',
        position INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (game_id) REFERENCES games(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_alliances_game ON game_alliances(game_id)');
    await db.execute('CREATE INDEX idx_alliances_team ON game_alliances(team_id)');

    // Team stats table
    await db.execute('''
      CREATE TABLE team_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        division_id INTEGER NOT NULL,
        team_id INTEGER NOT NULL DEFAULT 0,
        rank INTEGER NOT NULL DEFAULT 0,
        wins INTEGER NOT NULL DEFAULT 0,
        losses INTEGER NOT NULL DEFAULT 0,
        ties INTEGER NOT NULL DEFAULT 0,
        total_matches INTEGER NOT NULL DEFAULT 0,
        wp INTEGER NOT NULL DEFAULT 0,
        ap INTEGER NOT NULL DEFAULT 0,
        sp INTEGER NOT NULL DEFAULT 0,
        awp INTEGER NOT NULL DEFAULT 0,
        awp_rate REAL NOT NULL DEFAULT 0.0,
        opr REAL NOT NULL DEFAULT 0.0,
        dpr REAL NOT NULL DEFAULT 0.0,
        ccwm REAL NOT NULL DEFAULT 0.0,
        high_score INTEGER NOT NULL DEFAULT 0,
        avg_score REAL NOT NULL DEFAULT 0.0,
        total_score INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (division_id) REFERENCES divisions(id) ON DELETE CASCADE,
        UNIQUE(division_id, team_id)
      )
    ''');
    await db.execute('CREATE INDEX idx_stats_division ON team_stats(division_id)');
    await db.execute('CREATE INDEX idx_stats_team ON team_stats(team_id)');

    // Tournament skills table
    await db.execute('''
      CREATE TABLE tournament_skills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        team_id INTEGER NOT NULL DEFAULT 0,
        rank INTEGER NOT NULL DEFAULT 0,
        score INTEGER NOT NULL DEFAULT 0,
        auton_score INTEGER NOT NULL DEFAULT 0,
        auton_attempts INTEGER NOT NULL DEFAULT 0,
        driver_score INTEGER NOT NULL DEFAULT 0,
        driver_attempts INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE,
        UNIQUE(tournament_id, team_id)
      )
    ''');
    await db.execute('CREATE INDEX idx_skills_tournament ON tournament_skills(tournament_id)');

    // Awards table
    await db.execute('''
      CREATE TABLE awards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tournament_id INTEGER NOT NULL,
        name TEXT NOT NULL DEFAULT '',
        tournament_name TEXT,
        FOREIGN KEY (tournament_id) REFERENCES tournaments(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_awards_tournament ON awards(tournament_id)');

    // Award qualifications table
    await db.execute('''
      CREATE TABLE award_qualifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        award_id INTEGER NOT NULL,
        qualification TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (award_id) REFERENCES awards(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_award_qualifications_award ON award_qualifications(award_id)');

    // Award team winners table
    await db.execute('''
      CREATE TABLE award_team_winners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        award_id INTEGER NOT NULL,
        team_id INTEGER NOT NULL DEFAULT 0,
        team_number TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (award_id) REFERENCES awards(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_award_team_winners_award ON award_team_winners(award_id)');

    // Award individual winners table
    await db.execute('''
      CREATE TABLE award_individual_winners (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        award_id INTEGER NOT NULL,
        winner_name TEXT NOT NULL DEFAULT '',
        FOREIGN KEY (award_id) REFERENCES awards(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('CREATE INDEX idx_award_individual_winners_award ON award_individual_winners(award_id)');
  }

  /// Delete all data for a specific tournament (cascade handles related tables)
  Future<void> deleteTournament(int tournamentId) async {
    try {
      final db = await database;
      await db.delete('tournaments', where: 'id = ?', whereArgs: [tournamentId]);
    } catch (e) {
      print('Failed to delete tournament $tournamentId: $e');
    }
  }

  /// Clear all cached data
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete('tournaments');
    } catch (e) {
      print('Failed to clear all data: $e');
    }
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
