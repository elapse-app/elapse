import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';

class Award {
  String name;
  TournamentPreview tournament;
  List<String> qualifications;
  Team? team;

  Award({
    required this.name,
    required this.tournament,
    required this.qualifications,
    this.team,
  });
}
