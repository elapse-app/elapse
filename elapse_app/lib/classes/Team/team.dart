import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/sstats.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';

class Team {
  int id;
  String teamName;
  String teamdoubleber;
  Location location;
  String grade;

  List<Tournament> tournaments;

  TournamentStats? tStats;
  SeasonStats? sStats;

  Team({
    required this.id,
    required this.teamName,
    required this.teamdoubleber,
    required this.location,
    required this.grade,
    required this.tournaments,
    this.tStats,
    this.sStats,
  });
}
