import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elapse_app/classes/Team/team.dart';
import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/classes/Filters/season.dart';
import 'scout_sheet_data.dart';
import 'scouted_sheet.dart';

class ScoutedSheetPage {
  const ScoutedSheetPage(this.sheets, {this.nextCursor});
  final List<ScoutedSheet> sheets;
  final Object? nextCursor;
}

class ScoutedSheetRepository {
  final _teams = <int, Future<String>>{};
  final _events = <int, Future<List<TournamentPreview>>>{};
  static const pageSize = 25;

  Future<ScoutedSheetPage> load(String groupId, Object? cursor) async {
    var query = FirebaseFirestore.instance
        .collection('teamGroups')
        .doc(groupId)
        .collection('scoutsheets')
        .orderBy('latestUpdate', descending: true)
        .limit(pageSize);
    if (cursor is DocumentSnapshot) query = query.startAfterDocument(cursor);
    final snapshot = await query.get().timeout(const Duration(seconds: 20));
    final rows = <ScoutedSheet>[];
    // Resolve a bounded page; cached metadata is shared by sheets for one team.
    for (var offset = 0; offset < snapshot.docs.length; offset += 5) {
      rows.addAll(
          await Future.wait(snapshot.docs.skip(offset).take(5).map((doc) async {
        final raw = doc.data();
        final teamId = int.tryParse(raw['teamID']?.toString() ?? '') ?? 0;
        final eventId =
            int.tryParse(raw['tournamentID']?.toString() ?? '') ?? 0;
        final number = await _teams.putIfAbsent(teamId, () async {
          try {
            return (await fetchTeam(teamId).timeout(const Duration(seconds: 8)))
                    .teamNumber ??
                'Team $teamId';
          } on Object {
            return 'Team $teamId';
          }
        });
        final events = await _events.putIfAbsent(teamId, () async {
          try {
            return await fetchTeamTournaments(teamId, seasons.first.vrcId)
                .timeout(const Duration(seconds: 8));
          } on Object {
            return <TournamentPreview>[];
          }
        });
        final event = events.where((event) => event.id == eventId).firstOrNull;
        final timestamp = raw['latestUpdate'];
        return ScoutedSheet(
            id: doc.id,
            teamId: teamId,
            teamNumber: number,
            eventId: eventId,
            eventName: event?.name ?? 'Event $eventId',
            data: ScoutSheetData.fromFirestore(raw),
            updatedAt: timestamp is Timestamp ? timestamp.toDate() : null);
      })));
    }
    return ScoutedSheetPage(rows,
        nextCursor:
            snapshot.docs.length == pageSize ? snapshot.docs.last : null);
  }
}
