import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:flutter/material.dart';

List<Widget> EmptyState(BuildContext context, void Function() onPressed,
    {String? templateName}) {
  return [
    SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        margin: EdgeInsets.only(left: 23, right: 23, top: 8),
        padding: EdgeInsets.all(18),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.dynamic_form_outlined, size: 40),
            SizedBox(height: 10),
            Text(
              'Ready to scout this team?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              templateName == null
                  ? 'Create a sheet, choose your form, and start answering. You can reopen it from this team’s Scout sheet tab.'
                  : 'Create a sheet using $templateName and start answering. You can reopen it from this team’s Scout sheet tab.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
    SliverToBoxAdapter(
      child: SizedBox(
        height: 30,
      ),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: LongButton(
          text: "Create Scout Sheet",
          gradient: true,
          icon: Icons.list_alt_outlined,
          trailingIcon: Icons.edit_outlined,
          onPressed: onPressed,
        ),
      ),
    )
  ];
}
