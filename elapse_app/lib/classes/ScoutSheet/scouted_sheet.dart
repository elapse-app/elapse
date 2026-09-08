import 'scout_sheet_data.dart';

class ScoutedSheet {
  const ScoutedSheet(
      {required this.id,
      required this.teamId,
      required this.teamNumber,
      required this.eventId,
      required this.eventName,
      required this.data,
      this.updatedAt});

  final String id;
  final int teamId;
  final String teamNumber;
  final int eventId;
  final String eventName;
  final ScoutSheetData data;
  final DateTime? updatedAt;

  String get updatedLabel => updatedAt == null
      ? '—'
      : updatedAt!.toLocal().toIso8601String().substring(0, 10);

  static String answerText(Object? value) {
    if (value == null || value is String && value.trim().isEmpty) return '—';
    if (value is bool) return value ? 'Yes' : 'No';
    return value.toString();
  }

  /// Keep distinct questions distinct, even when their visible labels match.
  Map<String, String> get answerColumns => {
        for (final field in data.template.fields)
          '${data.template.id}/${field.id}':
              answerText(data.answerFor(field.id)),
      };

  Map<String, String> get columnLabels => {
        for (final field in data.template.fields)
          '${data.template.id}/${field.id}':
              '${field.section} / ${field.label}',
      };
}
