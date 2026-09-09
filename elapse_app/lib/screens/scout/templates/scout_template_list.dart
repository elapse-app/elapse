import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_template_repository.dart';
import 'package:elapse_app/screens/scout/templates/scout_template_editor.dart';
import 'package:elapse_app/screens/scout/start_scouting.dart';
import 'package:flutter/material.dart';

class ScoutTemplateListScreen extends StatefulWidget {
  const ScoutTemplateListScreen({
    super.key,
    required this.repository,
    this.onUseTemplate,
  });

  final ScoutTemplateRepository repository;
  final ValueChanged<ScoutSheetTemplate>? onUseTemplate;

  @override
  State<ScoutTemplateListScreen> createState() =>
      _ScoutTemplateListScreenState();
}

class _ScoutTemplateListScreenState extends State<ScoutTemplateListScreen> {
  late List<ScoutSheetTemplate> _templates;
  late String _defaultTemplateId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _templates = widget.repository.loadTemplates();
    _defaultTemplateId = widget.repository.loadDefaultTemplate().id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scout sheet templates')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('New template'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Text(
            'A template is a blank form. Tap Use template, choose a team, then create a scout sheet for an event and fill in your answers.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final template in _templates)
            _TemplateCard(
              template: template,
              isDefault: template.id == _defaultTemplateId,
              onSetDefault: () => _setDefault(template),
              onUse: () => _useTemplate(template),
              onEdit: template.isBuiltIn ? null : () => _openEditor(template),
              onDuplicate: () => _duplicate(template),
              onDelete: template.isBuiltIn ? null : () => _delete(template),
            ),
        ],
      ),
    );
  }

  void _useTemplate(ScoutSheetTemplate template) {
    if (widget.onUseTemplate != null) {
      widget.onUseTemplate!(template);
    } else {
      Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute(
            builder: (_) => StartScoutingScreen(template: template),
          ));
    }
  }

  Future<void> _openEditor([ScoutSheetTemplate? template]) async {
    final updated = await Navigator.push<ScoutSheetTemplate>(
      context,
      MaterialPageRoute(
        builder: (context) => ScoutTemplateEditorScreen(template: template),
      ),
    );
    if (updated == null) return;
    try {
      await widget.repository.saveTemplate(updated);
      if (!mounted) return;
      setState(_reload);
    } on Object catch (error) {
      if (!mounted) return;
      _showError(error);
    }
  }

  Future<void> _duplicate(ScoutSheetTemplate source) async {
    final now = DateTime.now();
    final duplicate = source.copyWith(
      id: 'custom-${now.microsecondsSinceEpoch.toRadixString(36)}',
      name: '${source.name} copy',
      createdAt: now,
      updatedAt: now,
      isBuiltIn: false,
    );
    await _openEditor(duplicate);
  }

  Future<void> _setDefault(ScoutSheetTemplate template) async {
    try {
      await widget.repository.setDefaultTemplate(template.id);
      if (!mounted) return;
      setState(() => _defaultTemplateId = template.id);
    } on Object catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _delete(ScoutSheetTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete template?'),
        content: Text(
          'Existing scout sheets made with “${template.name}” will keep their fields and answers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.repository.deleteTemplate(template.id);
    if (!mounted) return;
    setState(_reload);
  }

  void _showError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isDefault,
    required this.onSetDefault,
    required this.onDuplicate,
    required this.onUse,
    this.onEdit,
    this.onDelete,
  });

  final ScoutSheetTemplate template;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onDuplicate;
  final VoidCallback onUse;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: [
          ListTile(
            onTap: onUse,
            title: Text(template.name),
            subtitle: Text(
              '${template.fields.length} fields'
              '${template.isBuiltIn ? ' • Built in' : ''}'
              '${template.description.isEmpty ? '' : '\n${template.description}'}',
            ),
            isThreeLine: template.description.isNotEmpty,
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                switch (action) {
                  case 'edit':
                    onEdit?.call();
                  case 'duplicate':
                    onDuplicate();
                  case 'delete':
                    onDelete?.call();
                }
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                    value: 'duplicate', child: Text('Duplicate')),
                if (onDelete != null)
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Wrap(spacing: 8, runSpacing: 4, children: [
              FilledButton.icon(
                  onPressed: onUse,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Use template')),
              TextButton.icon(
                  onPressed: isDefault ? null : onSetDefault,
                  icon: Icon(isDefault ? Icons.star : Icons.star_border),
                  label: Text(
                      isDefault ? 'Default for new sheets' : 'Make default')),
            ]),
          ),
        ]),
      ),
    );
  }
}
