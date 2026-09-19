import 'package:elapse_app/classes/Filters/gradeLevel.dart';
import 'package:elapse_app/classes/Filters/levelClass.dart';
import 'package:elapse_app/classes/Filters/season.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/classes/Team/world_skills.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/main.dart' as app;
import 'package:elapse_app/screens/explore/filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const hasToken = bool.hasEnvironment('VEX_API_TOKEN');

  test(
    'team 10K loads every MOA feature from the live VEX API',
    () async {
      SharedPreferences.setMockInitialValues({
        'defaultGrade': 'High School',
      });
      app.prefs = await SharedPreferences.getInstance();

      final searchResults = await fetchTeamPreview('10K');
      final tenK =
          searchResults.singleWhere((team) => team.teamNumber == '10K');
      expect(tenK.teamID, 143646);

      final team = await fetchTeam(tenK.teamID);
      expect(team.teamName, 'Exothermic Knockout');

      final teamEvents = await fetchTeamTournaments(tenK.teamID, 204);
      expect(teamEvents.map((event) => event.id), contains(64244));

      final moaSearch = await getTournaments(
        'Mall of America',
        ExploreSearchFilter(
          season: seasons.first,
          levelClass: levelClasses.first,
          gradeLevel: gradeLevels['High School'],
          startDate: DateTime(2026, 8, 1),
          endDate: DateTime(2026, 8, 31),
        ),
        getAllPages: true,
      );
      expect(moaSearch.tournaments.map((event) => event.id), contains(64244));

      final moa = await getTournamentDetails(64244);
      expect(moa.teams.length, 118);
      expect(moa.teams.map((team) => team.id), contains(tenK.teamID));
      expect(moa.divisions, hasLength(1));
      expect(moa.divisions.single.games, hasLength(273));
      expect(moa.divisions.single.teamStats, contains(tenK.teamID));
      expect(moa.tournamentSkills, contains(tenK.teamID));
      expect(moa.awards, isNotEmpty);

      final tenKGames = moa.divisions.single.games!
          .where((game) => [
                ...game.redAlliancePreview!,
                ...game.blueAlliancePreview!,
              ].any((team) => team.teamID == tenK.teamID))
          .toList();
      expect(tenKGames, hasLength(9));

      for (final game in tenKGames) {
        final red =
            game.redAlliancePreview!.map((team) => team.teamNumber).join(' + ');
        final blue = game.blueAlliancePreview!
            .map((team) => team.teamNumber)
            .join(' + ');
        // Kept intentionally: this is the requested evidence from the live run.
        // ignore: avoid_print
        print(
            '${game.gameName}: $red ${game.redScore} - ${game.blueScore} $blue');
      }

      final teamAwards = await getAwards(tenK.teamID, 204);
      expect(teamAwards, isA<List<Award>>());

      final worldSkills =
          await getWorldSkillsRankings(204, gradeLevels['High School']!);
      expect(worldSkills, isNotEmpty);
    },
    skip: hasToken ? false : 'Set VEX_API_TOKEN to run live API checks.',
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
