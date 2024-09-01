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
        child: Text("Nothing here yet"),
      ),
    ),
    SliverToBoxAdapter(
      child: SizedBox(
        height: 15,
      ),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: LongButton(
          text: "Create Scoutsheet",
          gradient: true,
          icon: Icons.list_alt_outlined,
          trailingIcon: Icons.edit_outlined,
          onPressed: onPressed,
        ),
      ),
    )
  ];
}
