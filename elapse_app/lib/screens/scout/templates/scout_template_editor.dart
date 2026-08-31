import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:flutter/material.dart';

class ScoutTemplateEditorScreen extends StatefulWidget {
  const ScoutTemplateEditorScreen({
    super.key,
    this.template,
  });

  final ScoutSheetTemplate? template;

  @override
  State<ScoutTemplateEditorScreen> createState() =>
      _ScoutTemplateEditorScreenState();
}

class _ScoutTemplateEditorScreenState extends State<ScoutTemplateEditorScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late List<ScoutTemplateField> _fields;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.template?.description ?? '',
    );
    _fields = [...?widget.template?.fields];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'New template' : 'Edit template'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  TextField(
                    key: const ValueKey('template-name'),
                    controller: _nameController,
                    maxLength: 48,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Template name',
                      hintText: 'Competition scouting',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('template-description'),
                    controller: _descriptionController,
                    maxLength: 140,
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Fields',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Text('${_fields.length}/30'),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: _fields.length >= 30 ? null : () => _editField(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _fields.isEmpty
                  ? const _EmptyFields()
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: _fields.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final field = _fields.removeAt(oldIndex);
                          _fields.insert(newIndex, field);
                        });
                      },
                      itemBuilder: (context, index) {
                        final field = _fields[index];
                        return Card(
                          key: ValueKey(field.id),
                          child: ListTile(
                            leading: const Icon(Icons.drag_handle),
                            title: Text(field.label),
                            subtitle: Text(
                              '${field.section} • ${field.type.label}'
                              '${field.required ? ' • Required' : ''}',
                            ),
                            onTap: () => _editField(index),
                            trailing: IconButton(
                              tooltip: 'Delete field',
                              onPressed: () {
                                setState(() => _fields.removeAt(index));
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editField([int? index]) async {
    final existing = index == null ? null : _fields[index];
    final labelController = TextEditingController(text: existing?.label ?? '');
    final sectionController = TextEditingController(
      text: existing?.section ?? 'General',
    );
    final helperController = TextEditingController(
      text: existing?.helperText ?? '',
    );
    final optionsController = TextEditingController(
      text: existing?.options.join(', ') ?? '',
    );
    var type = existing?.type ?? ScoutFieldType.shortText;
    var isRequired = existing?.required ?? false;

    final result = await showDialog<ScoutTemplateField>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add field' : 'Edit field'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  key: const ValueKey('field-label'),
                  controller: labelController,
                  autofocus: true,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Label'),
                ),
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('field-section'),
                  controller: sectionController,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Section'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ScoutFieldType>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Answer type'),
                  items: [
                    for (final value in ScoutFieldType.values)
                      DropdownMenuItem(value: value, child: Text(value.label)),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => type = value);
                    }
                  },
                ),
                if (type == ScoutFieldType.singleChoice) ...[
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('field-options'),
                    controller: optionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Choices',
                      hintText: 'Option one, Option two',
                      helperText: 'Separate choices with commas.',
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                TextField(
                  key: const ValueKey('field-helper'),
                  controller: helperController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Helper text (optional)',
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Required'),
                  value: isRequired,
                  onChanged: (value) {
                    setDialogState(() => isRequired = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final label = labelController.text.trim();
                final options = optionsController.text
                    .split(',')
                    .map((option) => option.trim())
                    .where((option) => option.isNotEmpty)
                    .toList();
                final candidate = ScoutTemplateField(
                  id: existing?.id ?? _newFieldId(label),
                  label: label,
                  section: sectionController.text.trim().isEmpty
                      ? 'General'
                      : sectionController.text.trim(),
                  helperText: helperController.text.trim(),
                  type: type,
                  required: isRequired,
                  options: options,
                );
                final errors = candidate.validate();
                if (errors.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errors.first)),
                  );
                  return;
                }
                Navigator.pop(context, candidate);
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );

    // showDialog completes when pop begins, while its exit animation can still
    // build the text fields for one frame. Dispose after that route settles.
    await Future<void>.delayed(kThemeAnimationDuration);
    labelController.dispose();
    sectionController.dispose();
    helperController.dispose();
    optionsController.dispose();
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _fields.add(result);
      } else {
        _fields[index] = result;
      }
    });
  }

  void _save() {
    final now = DateTime.now();
    final template = ScoutSheetTemplate(
      id: widget.template?.id ??
          'custom-${now.microsecondsSinceEpoch.toRadixString(36)}',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      fields: _fields,
      createdAt: widget.template?.createdAt ?? now,
      updatedAt: now,
    );
    final errors = template.validate();
    if (errors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first)),
      );
      return;
    }
    Navigator.pop(context, template);
  }
}

class _EmptyFields extends StatelessWidget {
  const _EmptyFields();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dynamic_form_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            const Text('Add the questions your scouts should answer.'),
          ],
        ),
      ),
    );
  }
}

String _newFieldId(String label) {
  final slug = label
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  final prefix = slug.isEmpty ? 'field' : slug;
  final suffix = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  return '$prefix-$suffix';
}
