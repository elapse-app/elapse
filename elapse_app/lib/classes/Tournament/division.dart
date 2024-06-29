import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';

class Division {
  int id;
  String name;
  int order;
  List<Game>? games;
  List<Team>? teams;

  Division({
    required this.id,
    required this.name,
    required this.order,
    this.games,
    this.teams,
  });
}
