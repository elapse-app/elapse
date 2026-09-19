import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:flutter/material.dart';

List<Widget> EmptyState(BuildContext context, void Function() onPressed) {
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
        child: const Column(
          children: [
            Icon(Icons.dynamic_form_outlined, size: 40),
            SizedBox(height: 10),
            Text(
              'Nothing here yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Choose a template to start scouting this team.',
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
