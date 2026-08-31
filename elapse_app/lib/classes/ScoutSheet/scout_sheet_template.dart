import 'dart:convert';

import 'package:collection/collection.dart';

enum ScoutFieldType {
  shortText('short_text', 'Short text'),
  longText('long_text', 'Long text'),
  number('number', 'Number'),
  toggle('toggle', 'Yes / No'),
  singleChoice('single_choice', 'Single choice');

  const ScoutFieldType(this.storageKey, this.label);

  final String storageKey;
  final String label;

  static ScoutFieldType fromStorage(Object? value) {
    return ScoutFieldType.values.firstWhere(
      (type) => type.storageKey == value,
      orElse: () => ScoutFieldType.shortText,
    );
  }
}

class ScoutTemplateField {
  ScoutTemplateField({
    required this.id,
    required this.label,
    required this.type,
    this.section = 'General',
    this.helperText = '',
    this.required = false,
    List<String> options = const [],
  }) : options = List.unmodifiable(_normalizeOptions(options));

  factory ScoutTemplateField.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    final label = json['label']?.toString().trim() ?? '';
    if (id.isEmpty || label.isEmpty) {
      throw const FormatException(
          'Scout template fields need an id and label.');
    }

    return ScoutTemplateField(
      id: id,
      label: label,
      type: ScoutFieldType.fromStorage(json['type']),
      section: json['section']?.toString().trim().isNotEmpty == true
          ? json['section'].toString().trim()
          : 'General',
      helperText: json['helperText']?.toString().trim() ?? '',
      required: json['required'] == true,
      options: (json['options'] as List?)
              ?.map((option) => option.toString())
              .toList() ??
          const [],
    );
  }

  final String id;
  final String label;
  final ScoutFieldType type;
  final String section;
  final String helperText;
  final bool required;
  final List<String> options;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type.storageKey,
        'section': section,
        'helperText': helperText,
        'required': required,
        'options': options,
      };

  ScoutTemplateField copyWith({
    String? id,
    String? label,
    ScoutFieldType? type,
    String? section,
    String? helperText,
    bool? required,
    List<String>? options,
  }) {
    return ScoutTemplateField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      section: section ?? this.section,
      helperText: helperText ?? this.helperText,
      required: required ?? this.required,
      options: options ?? this.options,
    );
  }

  List<String> validate() {
    final errors = <String>[];
    if (id.trim().isEmpty) errors.add('Field id cannot be empty.');
    if (label.trim().isEmpty) errors.add('Field label cannot be empty.');
    if (type == ScoutFieldType.singleChoice && options.length < 2) {
      errors.add('$label needs at least two choices.');
    }
    return errors;
  }

  @override
  bool operator ==(Object other) {
    return other is ScoutTemplateField &&
        other.id == id &&
        other.label == label &&
        other.type == type &&
        other.section == section &&
        other.helperText == helperText &&
        other.required == required &&
        const ListEquality<String>().equals(other.options, options);
  }

  @override
  int get hashCode => Object.hash(
        id,
        label,
        type,
        section,
        helperText,
        required,
        const ListEquality<String>().hash(options),
      );
}

List<String> _normalizeOptions(List<String> options) {
  final normalized = <String>[];
  final seen = <String>{};
  for (final option in options) {
    final trimmed = option.trim();
    if (trimmed.isNotEmpty && seen.add(trimmed)) normalized.add(trimmed);
  }
  return normalized;
}

class ScoutSheetTemplate {
  ScoutSheetTemplate({
    required this.id,
    required this.name,
    required List<ScoutTemplateField> fields,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.isBuiltIn = false,
  }) : fields = List.unmodifiable(fields);

  factory ScoutSheetTemplate.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim() ?? '';
    final name = json['name']?.toString().trim() ?? '';
    final rawFields = json['fields'];
    if (id.isEmpty || name.isEmpty || rawFields is! List) {
      throw const FormatException('Invalid scout template.');
    }

    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '');
    return ScoutSheetTemplate(
      id: id,
      name: name,
      description: json['description']?.toString().trim() ?? '',
      fields: rawFields
          .whereType<Map>()
          .map((field) => ScoutTemplateField.fromJson(
                Map<String, dynamic>.from(field),
              ))
          .toList(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? createdAt ?? DateTime.now(),
      isBuiltIn: json['isBuiltIn'] == true,
    );
  }

  static final ScoutSheetTemplate standard = ScoutSheetTemplate(
    id: 'elapse-standard-v1',
    name: 'Robot overview',
    description: 'Drivetrain, intake, robot notes, and autonomous notes.',
    createdAt: DateTime.utc(2024),
    updatedAt: DateTime.utc(2024),
    isBuiltIn: true,
    fields: [
      ScoutTemplateField(
        id: 'intakeType',
        label: 'Intake type',
        type: ScoutFieldType.shortText,
        section: 'Robot specs',
      ),
      ScoutTemplateField(
        id: 'numMotors',
        label: 'Drivetrain motors',
        type: ScoutFieldType.number,
        section: 'Robot specs',
      ),
      ScoutTemplateField(
        id: 'RPM',
        label: 'Drivetrain RPM',
        type: ScoutFieldType.number,
        section: 'Robot specs',
      ),
      ScoutTemplateField(
        id: 'otherNotes',
        label: 'Other notes',
        type: ScoutFieldType.longText,
        section: 'Robot specs',
      ),
      ScoutTemplateField(
        id: 'autonNotes',
        label: 'Autonomous notes',
        type: ScoutFieldType.longText,
        section: 'Autonomous',
      ),
    ],
  );

  final String id;
  final String name;
  final String description;
  final List<ScoutTemplateField> fields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isBuiltIn;

  Map<String, dynamic> toJson() => {
        'schemaVersion': 1,
        'id': id,
        'name': name,
        'description': description,
        'fields': fields.map((field) => field.toJson()).toList(),
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'isBuiltIn': isBuiltIn,
      };

  String encode() => jsonEncode(toJson());

  ScoutSheetTemplate copyWith({
    String? id,
    String? name,
    String? description,
    List<ScoutTemplateField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBuiltIn,
  }) {
    return ScoutSheetTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  List<String> validate() {
    final errors = <String>[];
    if (name.trim().isEmpty) errors.add('Template name cannot be empty.');
    if (fields.isEmpty) errors.add('Add at least one field.');
    if (fields.length > 30) errors.add('Templates support up to 30 fields.');

    final ids = <String>{};
    for (final field in fields) {
      errors.addAll(field.validate());
      if (!ids.add(field.id)) {
        errors.add('Every field needs a unique id.');
      }
    }
    return errors;
  }

  @override
  bool operator ==(Object other) {
    return other is ScoutSheetTemplate &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        const ListEquality<ScoutTemplateField>().equals(other.fields, fields) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isBuiltIn == isBuiltIn;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        const ListEquality<ScoutTemplateField>().hash(fields),
        createdAt,
        updatedAt,
        isBuiltIn,
      );
}
