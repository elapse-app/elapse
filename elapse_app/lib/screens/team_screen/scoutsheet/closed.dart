import 'package:elapse_app/classes/ScoutSheet/scout_sheet_data.dart';
import 'package:elapse_app/classes/ScoutSheet/scout_sheet_template.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

List<Widget> ClosedState(
  BuildContext context,
  String teamNumber,
  ScoutSheetData sheet,
  String teamID,
  String tournamentID,
  void Function() deleteSheet,
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
        child: _ScoutAnswersSection(
          title: section.key,
          fields: section.value,
          sheet: sheet,
        ),
      ),
    SliverToBoxAdapter(child: _PhotoGallery(photos: sheet.photos)),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(23, 15, 23, 0),
        child: TextButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete scout sheet'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _confirmDelete(context, deleteSheet),
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
    ),
  ];
}

class _ScoutAnswersSection extends StatelessWidget {
  const _ScoutAnswersSection({
    required this.title,
    required this.fields,
    required this.sheet,
  });

  final String title;
  final List<ScoutTemplateField> fields;
  final ScoutSheetData sheet;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 23, right: 23),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          for (var index = 0; index < fields.length; index++) ...[
            _Answer(
                field: fields[index], value: sheet.answerFor(fields[index].id)),
            if (index != fields.length - 1)
              Divider(
                height: 24,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.14),
              ),
          ],
        ],
      ),
    );
  }
}

class _Answer extends StatelessWidget {
  const _Answer({required this.field, required this.value});

  final ScoutTemplateField field;
  final Object? value;

  @override
  Widget build(BuildContext context) {
    final displayValue = switch (field.type) {
      ScoutFieldType.toggle => value == null
          ? 'Not provided'
          : value == true
              ? 'Yes'
              : 'No',
      _ => value?.toString().trim().isNotEmpty == true
          ? value.toString()
          : 'Not provided',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayValue, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 2),
        Text(
          field.label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15, left: 23, right: 23),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          if (photos.isEmpty)
            const SizedBox(
              height: 96,
              child: Center(child: Text('No photos uploaded')),
            )
          else
            GridView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) => InkWell(
                onTap: () => _openPhotoViewer(context, photos, index),
                child: ClipRRect(
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
              ),
            ),
        ],
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

Future<void> _confirmDelete(
  BuildContext context,
  void Function() deleteSheet,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete scout sheet?'),
      content: const Text('This removes its answers and photos for the team.'),
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
  if (confirmed == true) deleteSheet();
}

void _openPhotoViewer(
  BuildContext context,
  List<String> photos,
  int initialIndex,
) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: PhotoViewGallery.builder(
          pageController: PageController(initialPage: initialIndex),
          itemCount: photos.length,
          builder: (context, index) => PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(photos[index]),
            initialScale: PhotoViewComputedScale.contained,
          ),
          loadingBuilder: (context, progress) => Center(
            child: CircularProgressIndicator(
              value: progress?.expectedTotalBytes == null
                  ? null
                  : progress!.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!,
            ),
          ),
        ),
      ),
    ),
  );
}
