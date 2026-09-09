import 'package:elapse_app/classes/ScoutSheet/scout_sheet_data.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:elapse_app/screens/team_screen/camera/photo_bottom_sheet.dart';
import 'package:flutter/material.dart';

List<Widget> EditState(
  BuildContext context,
  String teamNumber,
  String teamGroupId,
  void Function(String) addPhoto,
  void Function(int) removePhoto,
  List<String> photos,
  void Function(String fieldId, Object? value) updateAnswer,
  ScoutSheetData sheet,
) {
  final sections = _groupFields(sheet.template.fields);
  return [
    SliverPadding(
      padding: const EdgeInsets.fromLTRB(23, 8, 23, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sheet.template.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (sheet.template.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(sheet.template.description),
            ],
          ],
        ),
      ),
    ),
    for (final section in sections.entries)
      SliverToBoxAdapter(
        child: _ScoutSectionEditor(
          section: section.key,
          fields: section.value,
          sheet: sheet,
          onChanged: updateAnswer,
        ),
      ),
    SliverToBoxAdapter(
      child: _PhotoEditor(
        teamGroupId: teamGroupId,
        photos: photos,
        onAdd: addPhoto,
        onRemove: removePhoto,
      ),
    ),
    SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
    ),
  ];
}

class _ScoutSectionEditor extends StatelessWidget {
  const _ScoutSectionEditor({
    required this.section,
    required this.fields,
    required this.sheet,
    required this.onChanged,
  });

  final String section;
  final List<ScoutTemplateField> fields;
  final ScoutSheetData sheet;
  final void Function(String fieldId, Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      margin: const EdgeInsets.only(left: 23, right: 23, top: 15),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (var index = 0; index < fields.length; index++) ...[
            _ScoutFieldEditor(
              key: ValueKey(fields[index].id),
              field: fields[index],
              value: sheet.answerFor(fields[index].id),
              onChanged: (value) => onChanged(fields[index].id, value),
            ),
            if (index != fields.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _ScoutFieldEditor extends StatelessWidget {
  const _ScoutFieldEditor({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  final ScoutTemplateField field;
  final Object? value;
  final ValueChanged<Object?> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = '${field.label}${field.required ? ' *' : ''}';
    switch (field.type) {
      case ScoutFieldType.toggle:
        return SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: field.helperText.isEmpty ? null : Text(field.helperText),
          value: value == true,
          onChanged: onChanged,
        );
      case ScoutFieldType.singleChoice:
        final selected = field.options.contains(value) ? value as String : null;
        return DropdownButtonFormField<String>(
          initialValue: selected,
          decoration: _inputDecoration(label, field.helperText),
          items: [
            for (final option in field.options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: onChanged,
        );
      case ScoutFieldType.longText:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(label, field.helperText),
          onChanged: onChanged,
        );
      case ScoutFieldType.number:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration(label, field.helperText),
          onChanged: onChanged,
        );
      case ScoutFieldType.shortText:
        return TextFormField(
          initialValue: value?.toString() ?? '',
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration(label, field.helperText),
          onChanged: onChanged,
        );
    }
  }
}

class _PhotoEditor extends StatelessWidget {
  const _PhotoEditor({
    required this.teamGroupId,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final String teamGroupId;
  final List<String> photos;
  final void Function(String) onAdd;
  final void Function(int) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      margin: const EdgeInsets.only(left: 23, right: 23, top: 15),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Photos', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Text('${photos.length}/6'),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: photos.length + (photos.length < 6 ? 1 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              if (index == photos.length) {
                return _AddPhotoTile(
                  teamGroupId: teamGroupId,
                  onAdd: onAdd,
                );
              }
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton.filledTonal(
                      tooltip: 'Remove photo',
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.teamGroupId,
    required this.onAdd,
  });

  final String teamGroupId;
  final void Function(String) onAdd;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: () async {
        final result = await getPhoto(context, teamGroupId: teamGroupId);
        if (result != null) onAdd(result);
      },
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: Theme.of(context).colorScheme.tertiary,
        ),
        child: const Icon(Icons.add_photo_alternate_outlined, size: 36),
      ),
    );
  }
}

Map<String, List<ScoutTemplateField>> _groupFields(
  List<ScoutTemplateField> fields,
) {
  final sections = <String, List<ScoutTemplateField>>{};
  for (final field in fields) {
    sections.putIfAbsent(field.section, () => []).add(field);
  }
  return sections;
}

InputDecoration _inputDecoration(String label, String helperText) {
  return InputDecoration(
    labelText: label,
    helperText: helperText.isEmpty ? null : helperText,
  );
}
