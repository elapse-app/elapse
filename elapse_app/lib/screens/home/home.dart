import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/providers/tournament_mode_provider.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/settings/settings.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.teamID, required this.prefs});
  final int teamID;
  final SharedPreferences prefs;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    tournaments = fetchTeamTournaments(widget.teamID, 190);
  }

  Future<List<TournamentPreview>>? tournaments;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            automaticallyImplyLeading: false,
            expandedHeight: 120,
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1,
              collapseMode: CollapseMode.parallax,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Spacer(),
                    Text(
                      "Good Afternoon",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              background: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 12, bottom: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          SettingsButton(
                            prefs: widget.prefs,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              centerTitle: false,
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          const RoundedTop(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.all(Radius.circular(18))),
                child: FutureBuilder(
                  future: tournaments,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<TournamentPreview> teamTournaments =
                          snapshot.data as List<TournamentPreview>;
                      teamTournaments.removeWhere((item) {
                        return item.startDate == null ||
                            item.startDate!.difference(DateTime.now()).inDays <
                                -2;
                      });
                      if (teamTournaments.isEmpty) {
                        return Container();
                      }
                      TournamentPreview upcoming = teamTournaments[0];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TournamentScreen(
                                tournamentID: upcoming.id,
                              ),
                            ),
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(upcoming.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Icon(Icons.arrow_forward)
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Text(
                              "${upcoming.location?.city}, ${upcoming.location?.region}",
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                upcoming.startDate != null
                                    ? Text(
                                        "${DateFormat("EEE, MMM d, y").format(upcoming.startDate!)}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7)),
                                      )
                                    : Container(),
                                upcoming.endDate != null &&
                                        upcoming.endDate != upcoming.startDate
                                    ? Text(
                                        " - ${DateFormat("EEE, MMM d, y").format(upcoming.endDate!)}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withOpacity(0.7),
                                        ))
                                    : Container()
                              ],
                            ),
                            DateTime.now().compareTo(upcoming.endDate!) <= 0 &&
                                    DateTime.now()
                                            .difference(upcoming.startDate!)
                                            .inDays >
                                        -1
                                ? GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18)),
                                              title: Text(
                                                "Are you sure you want to enter Tournament Mode?",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    widget.prefs.setBool(
                                                        "isTournamentMode",
                                                        true);
                                                    widget.prefs.setInt(
                                                        "tournamentID",
                                                        upcoming.id);

                                                    myAppKey.currentState!
                                                        .reloadApp();

                                                    Provider.of<TournamentModeProvider>(
                                                            context,
                                                            listen: false)
                                                        .setTournamentMode(
                                                            true);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Confirm",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary),
                                                  ),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    child: Container(
                                      height: 64,
                                      margin: EdgeInsets.only(top: 25),
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(9))),
                                      child: Text(
                                        "Enter Tournament Mode",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Column();
                    } else {
                      return Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 23),
            sliver: SliverToBoxAdapter(
              child: FutureBuilder(
                  future: tournaments,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<TournamentPreview> teamTournaments =
                          snapshot.data as List<TournamentPreview>;
                      if (teamTournaments.length < 2) {
                        return Container();
                      }
                      teamTournaments.removeWhere((item) {
                        return item.startDate == null ||
                            item.startDate!.difference(DateTime.now()).inDays <
                                -2;
                      });
                      List<TournamentPreview> filteredTournaments =
                          teamTournaments.sublist(1);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upcoming",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: filteredTournaments.map(
                              (e) {
                                return TournamentPreviewWidget(
                                    tournamentPreview: e);
                              },
                            ).toList(),
                          )
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
