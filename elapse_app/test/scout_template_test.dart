import 'dart:convert';

import 'package:elapse_app/classes/ScoutSheet/scout_sheet_data.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_template_repository.dart';
import 'package:elapse_app/screens/scout/templates/scout_template_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScoutSheetTemplate', () {
    test('round trips every supported field type', () {
      final now = DateTime.utc(2026, 8, 30);
      final template = ScoutSheetTemplate(
        id: 'match-scouting',
        name: 'Match scouting',
        description: 'Fast match observations',
        createdAt: now,
        updatedAt: now,
        fields: [
          ScoutTemplateField(
            id: 'notes',
            label: 'Notes',
            type: ScoutFieldType.longText,
          ),
          ScoutTemplateField(
            id: 'score',
            label: 'Score',
            type: ScoutFieldType.number,
            required: true,
          ),
          ScoutTemplateField(
            id: 'climbed',
            label: 'Climbed',
            type: ScoutFieldType.toggle,
          ),
          ScoutTemplateField(
            id: 'role',
            label: 'Primary role',
            type: ScoutFieldType.singleChoice,
            options: const ['Offense', 'Defense'],
          ),
        ],
      );

      final decoded = ScoutSheetTemplate.fromJson(
        jsonDecode(template.encode()) as Map<String, dynamic>,
      );

      expect(decoded, template);
      expect(decoded.validate(), isEmpty);
    });

    test('validates required choices and duplicate field ids', () {
      final now = DateTime.utc(2026);
      final template = ScoutSheetTemplate(
        id: 'invalid',
        name: 'Invalid',
        createdAt: now,
        updatedAt: now,
        fields: [
          ScoutTemplateField(
            id: 'same',
            label: 'Role',
            type: ScoutFieldType.singleChoice,
            options: const ['Only one'],
          ),
          ScoutTemplateField(
            id: 'same',
            label: 'Notes',
            type: ScoutFieldType.shortText,
          ),
        ],
      );

      expect(template.validate(), hasLength(2));
    });
  });

  group('ScoutSheetData', () {
    test('deleted legacy photos stay deleted after a migrated sheet reloads',
        () {
      final legacy = <String, dynamic>{
        'properties': {
          'Specs': {
            'photos': ['old-photo']
          }
        },
      };
      final migrated = ScoutSheetData.fromFirestore(legacy).withPhotos([]);
      final persisted = {...legacy, ...migrated.toFirestore()};
      expect(ScoutSheetData.fromFirestore(persisted).photos, isEmpty);
    });

    test('migrates legacy Specs documents without losing answers', () {
      final sheet = ScoutSheetData.fromFirestore({
        'properties': {
          'Specs': {
            'intakeType': 'Double flywheel',
            'dbMotors': '6',
            'dbRPM': '450',
            'otherNotes': 'Fast cycle',
            'autonNotes': 'Reliable left side',
            'photos': ['https://example.com/robot.jpg'],
          },
        },
        'photos': <String>[],
      });

      expect(sheet.template, ScoutSheetTemplate.standard);
      expect(sheet.answerFor('intakeType'), 'Double flywheel');
      expect(sheet.answerFor('numMotors'), '6');
      expect(sheet.answerFor('RPM'), '450');
      expect(sheet.answerFor('autonNotes'), 'Reliable left side');
      expect(sheet.photos, ['https://example.com/robot.jpg']);
    });

    test('deduplicates choice values to prevent invalid dropdowns', () {
      final field = ScoutTemplateField(
        id: 'role',
        label: 'Role',
        type: ScoutFieldType.singleChoice,
        options: const ['Offense', ' Offense ', 'Defense'],
      );

      expect(field.options, ['Offense', 'Defense']);
      expect(field.validate(), isEmpty);
    });

    test('template snapshot and answers survive Firestore serialization', () {
      final original = ScoutSheetData.empty(ScoutSheetTemplate.standard)
          .withAnswer('intakeType', 'Hooks')
          .withAnswer('numMotors', '8')
          .withPhotos(['photo']);

      final restored = ScoutSheetData.fromFirestore(original.toFirestore());

      expect(restored.template, ScoutSheetTemplate.standard);
      expect(restored.answers, original.answers);
      expect(restored.photos, original.photos);
    });

    test('reports only empty required fields', () {
      final now = DateTime.utc(2026);
      final template = ScoutSheetTemplate(
        id: 'required',
        name: 'Required',
        createdAt: now,
        updatedAt: now,
        fields: [
          ScoutTemplateField(
            id: 'name',
            label: 'Name',
            type: ScoutFieldType.shortText,
            required: true,
          ),
          ScoutTemplateField(
            id: 'ready',
            label: 'Ready',
            type: ScoutFieldType.toggle,
            required: true,
          ),
        ],
      );

      final sheet = ScoutSheetData.empty(template)
          .withAnswer('name', '   ')
          .withAnswer('ready', false);

      expect(sheet.missingRequiredFields.map((field) => field.id), ['name']);
    });
  });

  group('ScoutTemplateRepository', () {
    test('persists custom and default templates', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = ScoutTemplateRepository(preferences);
      final now = DateTime.utc(2026);
      final template = ScoutSheetTemplate(
        id: 'custom',
        name: 'Custom',
        createdAt: now,
        updatedAt: now,
        fields: [
          ScoutTemplateField(
            id: 'notes',
            label: 'Notes',
            type: ScoutFieldType.longText,
          ),
        ],
      );

      await repository.saveTemplate(template);
      await repository.setDefaultTemplate(template.id);

      expect(repository.loadTemplates(), hasLength(2));
      expect(repository.loadDefaultTemplate().id, template.id);

      await repository.deleteTemplate(template.id);
      expect(repository.loadTemplates(), [ScoutSheetTemplate.standard]);
      expect(
        repository.loadDefaultTemplate(),
        ScoutSheetTemplate.standard,
      );
    });

    test('isolates corrupt stored templates', () async {
      SharedPreferences.setMockInitialValues({
        'scoutSheetTemplates.v1': [
          '{bad json',
          jsonEncode({'id': '', 'name': ''}),
        ],
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = ScoutTemplateRepository(preferences);

      expect(repository.loadTemplates(), [ScoutSheetTemplate.standard]);
    });
  });

  testWidgets('template editor creates a reusable custom form', (tester) async {
    ScoutSheetTemplate? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await Navigator.push<ScoutSheetTemplate>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ScoutTemplateEditorScreen(),
                    ),
                  );
                },
                child: const Text('Open editor'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('template-name')),
      'Pit scouting',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('field-label')),
      'Drive style',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(result?.name, 'Pit scouting');
    expect(result?.fields.single.label, 'Drive style');
    expect(result?.fields.single.type, ScoutFieldType.shortText);
  });
}
