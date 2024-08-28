import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:flutter/material.dart';

class CloudScoutScreen extends StatefulWidget {
  const CloudScoutScreen({super.key});

  @override
  State<CloudScoutScreen> createState() => _CloudScoutScreenState();
}

class _CloudScoutScreenState extends State<CloudScoutScreen> {
  @override
  Widget build(BuildContext context) {
    bool teamSync = true;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
              title: Text("CloudScout",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              includeSettings: true),
          RoundedTop(),
          teamSync
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                )
              : SliverToBoxAdapter()
        ],
      ),
    );
  }
}
