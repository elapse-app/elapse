import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';

class TournamentScope {
  final Tournament tournament;
  final Division division;

  const TournamentScope({required this.tournament, required this.division});
}
