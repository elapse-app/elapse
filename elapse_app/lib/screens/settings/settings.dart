import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Container(height: 300, color: Theme.of(context).colorScheme.primary),
          CustomScrollView(
            slivers: [
              SliverAppBar.medium(
                automaticallyImplyLeading: false,
                expandedHeight: 120,
                centerTitle: false,
                title: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                    ),
                    const Text("Settings",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w500)),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  height: 1000,
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
