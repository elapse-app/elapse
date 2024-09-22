import 'package:elapse_app/classes/Tournament/game.dart';

List<Game> getTeamGames(List<Game> games, String teamNumber) {
  bool isInGame(String teamNumber, Game game) {
    return game.blueAlliancePreview!.any((element) => element.teamNumber == teamNumber) ||
        game.redAlliancePreview!.any((element) => element.teamNumber == teamNumber);
  }

  List<Game> upcomingGames = games.where((game) {
    return isInGame(teamNumber, game);
  }).toList();

  return upcomingGames;
}

double _getDelay(List<Game> games) {
  int lastPlayed = games.lastIndexWhere((e) => e.startedTime != null);
  int n = 0;

  double total = 0;
  for (int i = lastPlayed; i >= 0 && n < 5; i--) {
    if (i > 0) {
      int timeSinceLastMatch = games[i].startedTime!.difference(games[i - 1].startedTime!).inMinutes;
      if (timeSinceLastMatch > 30) break;
    }

    total += games[i].startedTime!.difference(games[i].scheduledTime!).inMinutes;
    n++;
  }

  return n == 0 ? 0 : total / n;
}

void adjustMatchTiming(List<Game> games) {
  int lastPlayed = games.lastIndexWhere((e) => e.startedTime != null);
  double delay = 0;
  int n = 0;

  for (int i = lastPlayed; i >= 0 && n < 5; i--) {
    if (i > 0) {
      int timeSinceLastMatch;
      if (games[i].startedTime != null && games[i - 1].startedTime != null) {
        timeSinceLastMatch = games[i].startedTime!.difference(games[i - 1].startedTime!).inMinutes;
      } else {
        timeSinceLastMatch = 0;
      }
      if (timeSinceLastMatch > 30) break;
    }

    if (games[i].startedTime == null || games[i].scheduledTime == null) continue;
    delay += games[i].startedTime!.difference(games[i].scheduledTime!).inMinutes;
    n++;
  }

  delay *= n == 0 ? 0 : 1 / n;

  for (int i = lastPlayed + 1; i < games.length; i++) {
    if (i > 0) {
      if (games[i].scheduledTime == null) break;
      int timeSinceLastMatch = games[i].scheduledTime!.difference(games[i - 1].scheduledTime!).inMinutes;
      if (timeSinceLastMatch > 30) break;
    }

    games[i].adjustedTime = games[i].scheduledTime?.add(Duration(minutes: delay.round()));
  }
}

// double getCurrentDelay(List<Game> games) {
//   int delaySum = 0;
//   int count = 0;
//   int gameIndex = 0;
//   while (count < games.length && gameIndex == 0) {
//     if (games[count].startedTime == null) {
//       gameIndex = count - 1;
//     }
//     count++;
//   }
//
//   if (gameIndex <= 0) {
//     return 0;
//   }
//   count = 0;
//   int iterations = 0;
//   while (gameIndex > 0 && count < 5 && iterations < 10) {
//     if (games[gameIndex].startedTime != null && games[gameIndex].scheduledTime != null) {
//       delaySum += games[gameIndex].startedTime!.difference(games[gameIndex].scheduledTime!).inMinutes;
//       gameIndex--;
//       count++;
//     }
//     iterations++;
//   }
//   if (count == 0) {
//     return 0;
//   }
//
//   return delaySum / count;
// }
