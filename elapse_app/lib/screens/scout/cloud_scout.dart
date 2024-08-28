import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
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
    bool isTournamentMode = true;
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
                  child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Container(
                    padding: EdgeInsets.all(18),
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Theme.of(context).colorScheme.primary),
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
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 24),
                        LongButton(
                            onPressed: () {},
                            gradient: true,
                            text: "Sync Team Data",
                            icon: Icons.sync),
                      ],
                    ),
                  ),
                ))
              : SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 23),
                height: 64,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                    color: Theme.of(context).colorScheme.tertiary),
                child: isTournamentMode
                    ? Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            flex: 4,
                            child: Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.05),
                                onTap: () {
                                  print("clicked1");
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.contact_page_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                        SizedBox(width: 12),
                                        Text("ScoutSheets")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: VerticalDivider(
                                width: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.1),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Material(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                splashColor: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.05),
                                onTap: () {
                                  print("clicked2");
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.list_alt_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                        ],
                      )
                    : Container()),
          )
        ],
      ),
    );
  }
}
