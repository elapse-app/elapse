import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tskills.dart';
import 'package:elapse_app/classes/Tournament/tstats.dart';
import 'package:elapse_app/screens/tournament/pages/rankings/rankings_widget.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/game_widget.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage(
      {super.key,
      required this.searchQuery,
      required this.teams,
      required this.games,
      required this.skills,
      required this.rankings});

  final String searchQuery;
  final List<Team> teams;
  final List<Game> games;
  final Map<int, TeamStats> rankings;
  final Map<int, TournamentSkills> skills;

  @override
  Widget build(BuildContext context) {
    List<Team> filteredTeams = teams.where((e) {
      return (e.teamName!.toLowerCase().contains(searchQuery.toLowerCase()) ||
              e.teamNumber!
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase())) &&
          rankings[e.id] != null;
    }).toList();

    List<Game> filteredGames;
    if (filteredTeams.length > 10) {
      filteredGames = [];
    } else {
      filteredGames = games.where((game) {
        // Check if any team in filteredTeams is part of the blue or red alliances
        bool isPartOfAlliance(Team team, Game game) {
          return game.blueAlliancePreview!.any(
                  (blueTeam) => blueTeam.teamName.contains(team.teamNumber!)) ||
              game.redAlliancePreview!.any(
                  (redTeam) => redTeam.teamName.contains(team.teamNumber!));
        }

        // Return true if any team in filteredTeams is part of any alliance in the game

        return filteredTeams.any((team) =>
            isPartOfAlliance(team, game) ||
            game.gameName.contains(searchQuery.toUpperCase()));
      }).toList();
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 23.0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('"$searchQuery" in teams', style: TextStyle(fontSize: 20)),
            Divider(
              height: 3,
              color: Theme.of(context).colorScheme.surfaceDim,
            ),
            SizedBox(height: 10),
            Column(
              children: filteredTeams.map((e) {
                if (rankings[e.id] == null) {
                  return Container();
                }
                return StandardRanking(
                    teamStats: rankings[e.id]!,
                    rankings: rankings,
                    teamName: e.teamNumber!,
                    skills: skills,
                    games: games,
                    teamID: e.id,
                    allianceColor: Theme.of(context).colorScheme.onSurface);
              }).toList(),
            ),
            filteredGames.length > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text('"$searchQuery" in games',
                          style: TextStyle(fontSize: 20)),
                      Divider(
                        height: 3,
                        color: Theme.of(context).colorScheme.surfaceDim,
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: filteredGames.map((e) {
                          return GameWidget(
                              game: e,
                              rankings: rankings,
                              games: games,
                              skills: skills);
                        }).toList(),
                      )
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
