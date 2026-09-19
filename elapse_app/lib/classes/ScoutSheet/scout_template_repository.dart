import 'dart:convert';

import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoutTemplateRepository {
  ScoutTemplateRepository(this._preferences);

  static const _templatesKey = 'scoutSheetTemplates.v1';
  static const _defaultTemplateKey = 'defaultScoutSheetTemplate.v1';
  static const maxCustomTemplates = 25;

  final SharedPreferences _preferences;

  List<ScoutSheetTemplate> loadTemplates() {
    final customTemplates = <ScoutSheetTemplate>[];
    final seenIds = <String>{ScoutSheetTemplate.standard.id};
    for (final encoded
        in _preferences.getStringList(_templatesKey) ?? const []) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is! Map<String, dynamic>) continue;
        final template = ScoutSheetTemplate.fromJson(decoded);
        if (template.validate().isEmpty && seenIds.add(template.id)) {
          customTemplates.add(template.copyWith(isBuiltIn: false));
        }
      } on Object {
        // Ignore only the malformed template; valid user templates survive.
      }
    }
    customTemplates.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable([ScoutSheetTemplate.standard, ...customTemplates]);
  }

  ScoutSheetTemplate loadDefaultTemplate() {
    final templates = loadTemplates();
    final defaultId = _preferences.getString(_defaultTemplateKey);
    return templates.firstWhere(
      (template) => template.id == defaultId,
      orElse: () => ScoutSheetTemplate.standard,
    );
  }

  Future<void> saveTemplate(ScoutSheetTemplate template) async {
    if (template.isBuiltIn || template.id == ScoutSheetTemplate.standard.id) {
      throw ArgumentError('Built-in templates cannot be overwritten.');
    }
    final errors = template.validate();
    if (errors.isNotEmpty) throw ArgumentError(errors.first);

    final customTemplates =
        loadTemplates().where((candidate) => !candidate.isBuiltIn).toList();
    final existingIndex = customTemplates.indexWhere(
      (candidate) => candidate.id == template.id,
    );
    if (existingIndex == -1) {
      if (customTemplates.length >= maxCustomTemplates) {
        throw StateError(
          'You can save up to $maxCustomTemplates custom templates.',
        );
      }
      customTemplates.add(template);
    } else {
      customTemplates[existingIndex] = template;
    }

    await _preferences.setStringList(
      _templatesKey,
      customTemplates.map((item) => item.encode()).toList(),
    );
  }

  Future<void> deleteTemplate(String templateId) async {
    if (templateId == ScoutSheetTemplate.standard.id) return;
    final remaining = loadTemplates()
        .where((template) => !template.isBuiltIn && template.id != templateId)
        .map((template) => template.encode())
        .toList();
    await _preferences.setStringList(_templatesKey, remaining);
    if (_preferences.getString(_defaultTemplateKey) == templateId) {
      await _preferences.remove(_defaultTemplateKey);
    }
  }

  Future<void> setDefaultTemplate(String templateId) async {
    final exists = loadTemplates().any((template) => template.id == templateId);
    if (!exists) throw ArgumentError('Unknown scout template.');
    await _preferences.setString(_defaultTemplateKey, templateId);
  }
}
