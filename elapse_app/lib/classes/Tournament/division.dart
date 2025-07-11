import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';

class Division {
  int id;
  String name;
  int order;
  List<Game>? games;
  Map<int, TeamStats>? teamStats;

  Division(
      {required this.id,
      required this.name,
      required this.order,
      this.games,
      this.teamStats});

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "order": order,
      "games": games?.map((e) => e.toJson()).toList(),
      "teamStats": teamStats
          ?.map((key, value) => MapEntry(key.toString(), value.toJson())),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Division && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

Division loadDivision(division) {
  List<Game>? games = [];
  if (division["games"] != null) {
    for (var a in division["games"]) {
      games.add(loadGame(a));
    }
  }

  Map<String, dynamic>? stringedTeamStats = division["teamStats"];
  Map<int, TeamStats>? teamStats = null;

  if (stringedTeamStats != null) {
    teamStats = stringedTeamStats.map((key, value) {
      return MapEntry(int.parse(key), loadTeamStats(value));
    });
    return Division(
      id: division["id"],
      name: division["name"],
      order: division["order"],
      games: games,
      teamStats: teamStats,
    );
  } else {
    print('PRINT stringedTeamStats is null');
    return Division(
      id: division["id"],
      name: division["name"],
      order: division["order"],
      games: games,
      teamStats: null,
    );
  }
}

int getTeamDivisionIndex(List<Division> divisions, int teamID) {
  for (int i = 0; i < divisions.length; i++) {
    if (divisions[i].teamStats != null &&
        divisions[i].teamStats!.containsKey(teamID)) {
      return i;
    }
  }
  return -1;
}
