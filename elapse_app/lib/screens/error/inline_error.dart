import 'package:flutter/material.dart';

/// Shown in place of any widget that throws while building (installed as
/// [ErrorWidget.builder] in main.dart).
///
/// It must lay out safely wherever the failing widget was, including
/// unbounded constraints (e.g. inside a scroll view or a Row), so it uses only
/// a single [Text] — no Scaffold, Expanded, Spacer or LayoutBuilder. A
/// full-page Scaffold here gets an infinite size inside slivers, which
/// corrupts the render tree and crashes the app.
///
/// It also can't assume any ancestors exist (the error may be above
/// MaterialApp), so it supplies its own Directionality and text style.
class InlineErrorWidget extends StatelessWidget {
  const InlineErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text.rich(
          TextSpan(children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.error_outline, size: 18, color: colorScheme.error),
              ),
            ),
            const TextSpan(text: "Something went wrong loading this."),
          ]),
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
