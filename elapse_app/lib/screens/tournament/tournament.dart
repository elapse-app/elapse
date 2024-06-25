import 'package:elapse_app/classes/Tournament/division.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/requests/getTournament.dart';
import 'package:elapse_app/screens/tournament/pages/info.dart';
import 'package:elapse_app/screens/tournament/pages/rankings.dart';
import 'package:elapse_app/screens/tournament/pages/schedule/schedule.dart';
import 'package:elapse_app/screens/tournament/pages/skills.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:flutter/material.dart';

class TournamentScreen extends StatefulWidget {
  final int tournamentID;
  const TournamentScreen({super.key, required this.tournamentID});

  @override
  State<TournamentScreen> createState() => _TournamentScreenState();
}

class _TournamentScreenState extends State<TournamentScreen> {
  Future<Tournament>? tournament;
  int selectedIndex = 0;

  Division? division;

  List<String> titles = ["Schedule", "Rankings", "Skills", "Info"];

  @override
  void initState() {
    super.initState();

    tournament = getTournamentDetails(widget.tournamentID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 125,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      titles[selectedIndex],
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 30,
                      ),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
              centerTitle: false,
              background: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 12, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder(
                            future: tournament,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (division == null &&
                                    snapshot.data!.divisions.isNotEmpty) {
                                  division = snapshot.data!.divisions[0];
                                }
                                return DropdownButton<Division>(
                                  value: division,
                                  borderRadius: BorderRadius.circular(20),
                                  items: snapshot.data!.divisions
                                      .map<DropdownMenuItem<Division>>(
                                          (division) {
                                    return DropdownMenuItem(
                                        value: division,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.groups_3_outlined,
                                              size: 30,
                                            ),
                                            SizedBox(width: 10),
                                            Text(division.name),
                                          ],
                                        ));
                                  }).toList(),
                                  onChanged: (Division? value) => {
                                    setState(() {
                                      division = value!;
                                      selectedIndex = selectedIndex;
                                    })
                                  },
                                );
                              } else {
                                return const Text("Fetching Divisions");
                              }
                            },
                          ),
                          const Spacer(),
                          const SettingsButton()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate(
                minHeight: 70.0,
                maxHeight: 70.0,
                child: Stack(
                  children: [
                    Container(
                        height: 300,
                        color: Theme.of(context).colorScheme.primary),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildIconButton(
                                context, Icons.calendar_view_day_outlined, 0),
                            _buildIconButton(context,
                                Icons.format_list_numbered_outlined, 1),
                            _buildIconButton(
                                context, Icons.sports_esports_outlined, 2),
                            _buildIconButton(context, Icons.info_outlined, 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          FutureBuilder(
              future: tournament,
              builder: ((builder, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("Failed to load tournament"),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  if (division == null && snapshot.data!.divisions.isNotEmpty) {
                    division = snapshot.data!.divisions[0];
                  }
                  List<Widget> pages = [
                    SchedulePage(
                        divisionID: division?.id,
                        tournamentID: widget.tournamentID),
                    const RankingsPage(),
                    const SkillsPage(),
                    const InfoPage(),
                  ];
                  return pages[selectedIndex];
                } else {
                  return const SliverToBoxAdapter();
                }
              })),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selectedIndex == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
          ),
        ),
        IconButton(
          highlightColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () async {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ],
    );
  }
}
