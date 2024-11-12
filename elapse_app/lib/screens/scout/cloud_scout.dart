import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/team_widget.dart';
import 'package:flutter/material.dart';

import '../tournament_mode/picklist/picklist.dart';

class CloudScoutScreen extends StatefulWidget {
  const CloudScoutScreen({super.key});

  @override
  State<CloudScoutScreen> createState() => _CloudScoutScreenState();
}

class _CloudScoutScreenState extends State<CloudScoutScreen> {
  @override
  Widget build(BuildContext context) {
    bool teamSync = true;
    List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
    List<TeamPreview> savedTeamPreview = savedTeams.map((e) => loadTeamPreview(e)).toList();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          ElapseAppBar(
            title: Text("CloudScout", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
            includeSettings: true,
            settingsCallback: () => setState(() {}),
          ),
          RoundedTop(),
          !teamSync
              ? SliverToBoxAdapter(
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Container(
                    padding: EdgeInsets.all(18),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(18)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TeamSync",
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 18),
                        Text(
                          "Sync your ScoutSheets with your teammates.",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 24),
                        LongButton(onPressed: () {}, gradient: true, text: "Sync Team Data", icon: Icons.sync),
                      ],
                    ),
                  ),
                ))
              : SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: prefs.getBool("isTournamentMode") ?? false
                ? Column(children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 23),
                      height: 64,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(18),
                          ),
                          color: Theme.of(context).colorScheme.tertiary),
                      child: Material(
                        color: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PicklistPage(),
                                ));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_alt_outlined,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  SizedBox(width: 12),
                                  Text("My Picklist")
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 18,
                    ),
                  ])
                : const SizedBox.shrink(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23.0),
              child: Text(
                "Saved Teams",
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          savedTeams == null || savedTeams.isEmpty
              ? SliverToBoxAdapter(
                  child: BigErrorMessage(
                      icon: Icons.bookmark_add_outlined, message: "Add some teams from the explore menu"),
                )
              : SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        TeamPreview savedTeam = savedTeamPreview[index];
                        print(savedTeam.teamName);
                        return Column(
                          children: [
                            TeamWidget(
                                teamNumber: savedTeam.teamNumber,
                                teamID: savedTeam.teamID,
                                location: savedTeam.location,
                                teamName: savedTeam.teamName),
                            Divider(
                              color: Theme.of(context).colorScheme.surfaceDim,
                              height: 3,
                            )
                          ],
                        );
                      },
                      childCount: savedTeamPreview.length,
                    ),
                  ),
                ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 18,
            ),
          ),
          // teamSync
          //     ? SliverToBoxAdapter(
          //         child: Padding(
          //           padding: EdgeInsets.symmetric(horizontal: 23),
          //           child: Container(
          //             padding: EdgeInsets.all(18),
          //             margin: EdgeInsets.only(bottom: 12),
          //             decoration: BoxDecoration(
          //               border: Border.all(
          //                   width: 1,
          //                   color: Theme.of(context).colorScheme.primary),
          //               borderRadius: BorderRadius.circular(18),
          //             ),
          //             child: Column(
          //               children: [
          //                 Row(
          //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                   children: [
          //                     Text(
          //                       "TeamSync Enabled",
          //                       style: TextStyle(fontSize: 24),
          //                     ),
          //                     Icon(Icons.sync,
          //                         color:
          //                             Theme.of(context).colorScheme.secondary)
          //                   ],
          //                 ),
          //                 SizedBox(height: 18),
          //                 const Row(
          //                   children: [
          //                     Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Text(
          //                           '00',
          //                           style:
          //                               TextStyle(fontWeight: FontWeight.w500),
          //                         ),
          //                         Text("Teammates")
          //                       ],
          //                     ),
          //                     SizedBox(width: 18),
          //                     Column(
          //                       crossAxisAlignment: CrossAxisAlignment.start,
          //                       children: [
          //                         Text(
          //                           '0 Mins ago',
          //                           style:
          //                               TextStyle(fontWeight: FontWeight.w500),
          //                         ),
          //                         Text("Last updated")
          //                       ],
          //                     ),
          //                   ],
          //                 )
          //               ],
          //             ),
          //           ),
          //         ),
          //       )
          //     : SliverToBoxAdapter(),
        ],
      ),
    );
  }
}
