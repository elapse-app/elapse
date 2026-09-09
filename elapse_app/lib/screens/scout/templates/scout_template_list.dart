import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_template_repository.dart';
import 'package:elapse_app/screens/scout/templates/scout_template_editor.dart';
import 'package:flutter/material.dart';

class ScoutTemplateListScreen extends StatefulWidget {
  const ScoutTemplateListScreen({
    super.key,
    required this.repository,
  });

  final ScoutTemplateRepository repository;

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
            'Pick a default or build reusable forms for different scouting jobs.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          for (final template in _templates)
            _TemplateCard(
              template: template,
              isDefault: template.id == _defaultTemplateId,
              onSetDefault: () => _setDefault(template),
              onEdit: template.isBuiltIn ? null : () => _openEditor(template),
              onDuplicate: () => _duplicate(template),
              onDelete: template.isBuiltIn ? null : () => _delete(template),
            ),
        ],
      ),
    );
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
    await widget.repository.setDefaultTemplate(template.id);
    if (!mounted) return;
    setState(() => _defaultTemplateId = template.id);
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
    this.onEdit,
    this.onDelete,
  });

  final ScoutSheetTemplate template;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final VoidCallback onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Radio<String>(
            value: template.id,
            groupValue: isDefault ? template.id : null,
            onChanged: (_) => onSetDefault(),
          ),
          onTap: onSetDefault,
          title: Row(
            children: [
              Expanded(child: Text(template.name)),
              if (template.isBuiltIn)
                const Chip(
                  label: Text('Built in'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          subtitle: Text(
            '${template.fields.length} fields'
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
              const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
              if (onDelete != null)
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
      ),
    );
  }
}
