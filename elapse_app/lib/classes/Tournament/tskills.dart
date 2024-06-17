import 'package:elapse_app/classes/Team/team.dart';

class TournamentSkills {
  int score;

  int autonScore;
  int autonAttempts;

  int driverScore;
  int driverAttempts;
  int rank;

  Team team;

  TournamentSkills({
    required this.score,
    required this.autonScore,
    required this.autonAttempts,
    required this.driverScore,
    required this.driverAttempts,
    required this.rank,
    required this.team,
  });
}
