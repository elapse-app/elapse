import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/game.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('team parser supports VEX API v2 data', () {
    final team = Team.fromJson({
      'id': 143646,
      'number': '10K',
      'team_name': 'Exothermic Knockout',
      'organization': 'Exothermic Robotics',
      'grade': 'High School',
      'location': {
        'address_1': '',
        'address_2': null,
        'city': 'Bellevue',
        'region': 'Washington',
        'country': 'United States',
      },
    });

    expect(team.id, 143646);
    expect(team.teamNumber, '10K');
    expect(team.location?.city, 'Bellevue');
    expect(team.grade?.name, 'High School');
  });

  test('event and elimination match parsers support current VEX data', () {
    final event = TournamentPreview.fromJson({
      'id': 64244,
      'sku': 'RE-V5RC-26-4244',
      'name': 'Mall of America',
      'start': '2026-08-06T00:00:00-04:00',
      'end': '2026-08-08T00:00:00-04:00',
      'location': {
        'venue': 'Mall of America',
        'address_1': '60 East Broadway',
        'address_2': null,
        'city': 'Bloomington',
        'region': 'Minnesota',
        'country': 'United States',
      },
    });
    final game = Game.fromJson({
      'round': 3,
      'instance': 1,
      'matchnum': 1,
      'name': 'R16 #1-1',
      'field': 'Digikey',
      'scheduled': '2026-08-08T16:00:00-04:00',
      'started': '2026-08-08T16:03:00-04:00',
      'alliances': [
        {
          'color': 'red',
          'score': 100,
          'teams': [
            {
              'team': {'id': 143646, 'name': '10K'}
            },
            {
              'team': {'id': 1, 'name': '10G'}
            },
          ],
        },
        {
          'color': 'blue',
          'score': 90,
          'teams': [
            {
              'team': {'id': 2, 'name': '96Z'}
            },
            {
              'team': {'id': 3, 'name': '2145X'}
            },
          ],
        },
      ],
    });

    expect(event.id, 64244);
    expect(game.gameName, 'R161');
    expect(game.redAlliancePreview!.first.teamNumber, '10K');
    expect(game.blueScore, 90);
  });

  test('award parser supports current winner objects', () {
    final award = Award.fromJson({
      'title': 'Tournament Champions (VRC/VEXU/VAIRC)',
      'qualifications': ['World Championship'],
      'event': {'name': 'MOA'},
      'teamWinners': [
        {
          'team': {'id': 143646, 'name': '10K'},
        }
      ],
      'individualWinners': <String>[],
    });

    expect(award.name.trim(), 'Tournament Champions');
    expect(award.qualifications, ['WC']);
    expect(award.teamWinners!.single.teamNumber, '10K');
  });

  test('missing API token fails with an actionable message', () {
    const configuredToken = String.fromEnvironment('VEX_API_TOKEN');
    if (configuredToken.isEmpty) {
      expect(getToken, throwsA(isA<StateError>()));
    } else {
      expect(getToken(), startsWith('Bearer '));
    }
  });
}
