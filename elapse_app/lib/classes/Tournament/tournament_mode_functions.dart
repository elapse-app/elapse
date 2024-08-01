import 'package:elapse_app/classes/Tournament/game.dart';

List<Game> getTeamGames(List<Game> games, String teamNumber) {
  bool isInGame(String teamNumber, Game game) {
    return game.blueAlliancePreview!
            .any((element) => element.teamNumber == teamNumber) ||
        game.redAlliancePreview!
            .any((element) => element.teamNumber == teamNumber);
  }

  List<Game> upcomingGames = games.where((game) {
    return isInGame(teamNumber, game);
  }).toList();

  return upcomingGames;
}

double getCurrentDelay(List<Game> games) {
  int delaySum = 0;
  int count = 0;
  int gameIndex = 0;
  while (count < games.length && gameIndex == 0) {
    if (games[count].startedTime == null) {
      gameIndex = count - 1;
    }
    count++;
  }

  if (gameIndex <= 0) {
    return 0;
  }
  count = 0;
  int iterations = 0;
  while (gameIndex > 0 && count < 5 && iterations < 10) {
    if (games[gameIndex].startedTime != null &&
        games[gameIndex].scheduledTime != null) {
      print("condition");
      delaySum += games[gameIndex]
          .startedTime!
          .difference(games[gameIndex].scheduledTime!)
          .inMinutes;
      gameIndex--;
      count++;
    }
    iterations++;
  }
  if (count == 0) {
    return 0;
  }

  return delaySum / count;
}
