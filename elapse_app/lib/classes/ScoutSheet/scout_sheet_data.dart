import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';

class ScoutSheetData {
  ScoutSheetData({
    required this.template,
    Map<String, Object?> answers = const {},
    List<String> photos = const [],
  })  : answers = Map.unmodifiable(answers),
        photos = List.unmodifiable(photos);

  factory ScoutSheetData.empty(ScoutSheetTemplate template) {
    return ScoutSheetData(template: template);
  }

  factory ScoutSheetData.fromFirestore(Map<String, dynamic> json) {
    ScoutSheetTemplate template = ScoutSheetTemplate.standard;
    final rawTemplate = json['template'];
    if (rawTemplate is Map) {
      try {
        template = ScoutSheetTemplate.fromJson(
          Map<String, dynamic>.from(rawTemplate),
        );
      } on Object {
        template = ScoutSheetTemplate.standard;
      }
    }

    final answers = <String, Object?>{};
    final rawAnswers = json['answers'];
    if (rawAnswers is Map) {
      for (final entry in rawAnswers.entries) {
        answers[entry.key.toString()] = entry.value;
      }
    } else {
      final properties = json['properties'];
      final specs = properties is Map ? properties['Specs'] : null;
      if (specs is Map) {
        answers.addAll({
          'intakeType': specs['intakeType'] ?? '',
          'numMotors': specs['numMotors'] ?? specs['dbMotors'] ?? '',
          'RPM': specs['RPM'] ?? specs['dbRPM'] ?? '',
          'otherNotes': specs['otherNotes'] ?? '',
          'autonNotes': specs['autonNotes'] ?? '',
        });
      }
    }

    final rawRootPhotos = json['photos'];
    final properties = json['properties'];
    final specs = properties is Map ? properties['Specs'] : null;
    final rawLegacyPhotos = specs is Map ? specs['photos'] : null;
    final rawPhotos = rawRootPhotos is List && rawRootPhotos.isNotEmpty
        ? rawRootPhotos
        : rawLegacyPhotos is List
            ? rawLegacyPhotos
            : rawRootPhotos;

    return ScoutSheetData(
      template: template,
      answers: answers,
      photos: rawPhotos is List
          ? rawPhotos.map((photo) => photo.toString()).toList()
          : const [],
    );
  }

  final ScoutSheetTemplate template;
  final Map<String, Object?> answers;
  final List<String> photos;

  Object? answerFor(String fieldId) => answers[fieldId];

  ScoutSheetData withAnswer(String fieldId, Object? value) {
    return ScoutSheetData(
      template: template,
      answers: {...answers, fieldId: value},
      photos: photos,
    );
  }

  ScoutSheetData withPhotos(List<String> value) {
    return ScoutSheetData(
      template: template,
      answers: answers,
      photos: value,
    );
  }

  List<ScoutTemplateField> get missingRequiredFields {
    return template.fields.where((field) {
      if (!field.required) return false;
      final value = answers[field.id];
      if (value == null) return true;
      if (value is String) return value.trim().isEmpty;
      return false;
    }).toList();
  }

  Map<String, dynamic> toFirestore() => {
        'schemaVersion': 2,
        'template': template.toJson(),
        'answers': answers,
        'photos': photos,
      };
}
