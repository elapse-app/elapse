import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
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
    expect(event.sku, 'RE-V5RC-26-4244');
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

  test('API token is normalized into a Bearer authorization header', () {
    expect(buildAuthorizationHeader('token'), 'Bearer token');
    expect(buildAuthorizationHeader(' Bearer token '), 'Bearer token');
    expect(() => buildAuthorizationHeader('  '), throwsStateError);
  });

  test('saved team parser rejects corrupt local data without crashing', () {
    expect(tryLoadTeamPreview(null), isNull);
    expect(tryLoadTeamPreview(''), isNull);
    expect(tryLoadTeamPreview('{"teamID":"not-a-number"}'), isNull);

    final team = tryLoadTeamPreview(
      '{"teamID":143646,"teamNumber":"10K","grade":"High School"}',
    );
    expect(team?.teamID, 143646);
    expect(team?.teamNumber, '10K');
  });

  test('team preview equality and hash code use the same identity', () {
    final first = TeamPreview(teamID: 143646, teamNumber: '10K');
    final renamed = TeamPreview(teamID: 143646, teamNumber: '10K-new');

    expect(first, renamed);
    expect(first.hashCode, renamed.hashCode);
    expect({first, renamed}, hasLength(1));
  });

  test('upcoming tournament filtering is immutable and date ordered', () {
    final source = [
      TournamentPreview(
        id: 1,
        name: 'Past',
        startDate: DateTime(2026, 8, 1),
        endDate: DateTime(2026, 8, 2),
      ),
      TournamentPreview(
        id: 3,
        name: 'Later',
        startDate: DateTime(2026, 8, 25),
        endDate: DateTime(2026, 8, 26),
      ),
      TournamentPreview(
        id: 2,
        name: 'Active',
        startDate: DateTime(2026, 8, 20),
        endDate: DateTime(2026, 8, 22),
      ),
    ];

    final result = upcomingTournaments(source, DateTime(2026, 8, 21));

    expect(result.map((event) => event.id), [2, 3]);
    expect(source.map((event) => event.id), [1, 3, 2]);
    expect(() => result.add(source.first), throwsUnsupportedError);
  });

  test('tournament mode is only active during inclusive event dates', () {
    final event = TournamentPreview(
      id: 1,
      name: 'Event',
      startDate: DateTime(2026, 8, 21),
      endDate: DateTime(2026, 8, 23),
    );

    expect(isTournamentActive(event, DateTime(2026, 8, 20, 23, 59)), isFalse);
    expect(isTournamentActive(event, DateTime(2026, 8, 21)), isTrue);
    expect(isTournamentActive(event, DateTime(2026, 8, 23, 23, 59)), isTrue);
    expect(isTournamentActive(event, DateTime(2026, 8, 24)), isFalse);
  });

  test('event parser tolerates missing optional location and dates', () {
    final event = TournamentPreview.fromJson({
      'id': 42,
      'name': 'Undated event',
      'location': null,
      'start': null,
      'end': null,
    });

    expect(event.location, isNull);
    expect(event.startDate, isNull);
    expect(event.endDate, isNull);
  });
}
