import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';

class Award {
  String name;
  Tournament tournament;
  String qualification;
  Team? team;

  Award({
    required this.name,
    required this.tournament,
    required this.qualification,
    this.team,
  });
}
