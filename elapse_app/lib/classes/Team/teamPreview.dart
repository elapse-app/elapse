import 'dart:convert';
import 'dart:io';

import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:elapse_app/extras/token.dart';
import 'package:http/http.dart' as http;

import '../Filters/gradeLevel.dart';
import '../Filters/season.dart';

class TeamPreview {
  final String teamNumber;
  final int teamID;
  Location? location;
  String? teamName;
  GradeLevel? gradeLevel;

  TeamPreview({
    required this.teamNumber,
    required this.teamID,
    this.location,
    this.teamName,
    this.gradeLevel,
  });

  factory TeamPreview.fromJson(Map<String, dynamic> json) {
    final teamNumber = json['teamNumber'];
    final teamId = json['teamID'];

    if (teamNumber is! String || teamNumber.trim().isEmpty || teamId is! num) {
      throw const FormatException('Invalid saved team');
    }

    final locationJson = json['location'];
    return TeamPreview(
      teamNumber: teamNumber,
      teamID: teamId.toInt(),
      location: locationJson is Map<String, dynamic>
          ? loadLocation(locationJson)
          : null,
      teamName: json['teamName'] as String?,
      gradeLevel: gradeLevels[json['grade']],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamNumber': teamNumber,
      'teamID': teamID,
      'location': location?.toJson(),
      'teamName': teamName,
      'grade': gradeLevel?.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeamPreview && other.teamID == teamID;
  }

  @override
  int get hashCode => teamID.hashCode;
}

TeamPreview loadTeamPreview(String? teamPreview) {
  if (teamPreview == null || teamPreview.trim().isEmpty) {
    throw const FormatException('Invalid saved team');
  }
  final decoded = jsonDecode(teamPreview);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid saved team');
  }
  return TeamPreview.fromJson(decoded);
}

TeamPreview? tryLoadTeamPreview(String? teamPreview) {
  if (teamPreview == null || teamPreview.trim().isEmpty) {
    return null;
  }

  try {
    return loadTeamPreview(teamPreview);
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}

Future<List<TeamPreview>> fetchTeamPreview(String searchQuery) async {
  final normalizedQuery = searchQuery.trim();
  if (normalizedQuery.isEmpty) {
    return [];
  }

  final vdaSearch = getTrueSkillData(seasons[0].vrcId)
      .timeout(const Duration(seconds: 5))
      .then((value) => value.where((element) {
            final query = normalizedQuery.toLowerCase();
            return element.teamNum.toLowerCase().contains(query) ||
                (element.teamName?.toLowerCase().contains(query) ?? false);
          }).map((e) => TeamPreview(
                teamNumber: e.teamNum,
                teamID: e.id,
                location: e.location,
                teamName: e.teamName,
                gradeLevel: e.gradeLevel,
              )))
      .catchError((_) => <TeamPreview>[]);

  final response = await http.get(
    Uri.parse(
        'https://events.vex.com/api/v2/teams?number%5B%5D=${Uri.encodeQueryComponent(normalizedQuery)}&program%5B%5D=1&program%5B%5D=4&myTeams=false'),
    headers: {
      HttpHeaders.authorizationHeader: getToken(),
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to load team preview (${response.statusCode})');
  }

  final responseData = jsonDecode(response.body)['data'] as List;
  final teams = responseData
      .map<TeamPreview>((team) => TeamPreview(
            teamNumber: team['number'],
            teamID: team['id'],
            teamName: team['team_name'],
            location: Location(
              address1: team['location']['address_1'],
              address2: team['location']['address_2'],
              city: team['location']['city'],
              region: team['location']['region'],
              country: team['location']['country'],
              venue: team['location']['venue'],
            ),
            gradeLevel: gradeLevels[team['grade']],
          ))
      .toList();

  if (teams.isEmpty) {
    teams.addAll(await vdaSearch);
  }
  return {for (final team in teams) team.teamID: team}.values.toList();
}
