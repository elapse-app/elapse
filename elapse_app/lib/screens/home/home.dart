import 'package:elapse_app/classes/Tournament/tournament_preview.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/providers/tournament_mode_provider.dart';
import 'package:elapse_app/screens/tournament/tournament.dart';
import 'package:elapse_app/screens/widgets/app_bar.dart';
import 'package:elapse_app/screens/widgets/long_button.dart';
import 'package:elapse_app/screens/widgets/rounded_top.dart';
import 'package:elapse_app/screens/widgets/settings_button.dart';
import 'package:elapse_app/screens/widgets/tournament_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../classes/Filters/season.dart';
import '../../classes/Team/teamPreview.dart';
import '../widgets/big_error_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    tournaments = fetchTeamTournaments(loadTeamPreview(prefs.getString("savedTeam")).teamID, seasons[0].vrcId);
  }

  Future<List<TournamentPreview>>? tournaments;
  @override
  Widget build(BuildContext context) {
    String welcomeMessage = "Good Afternoon";
    if (DateTime.now().hour < 12) {
      welcomeMessage = "Good Morning";
    } else if (DateTime.now().hour < 18) {
      welcomeMessage = "Good Afternoon";
    } else {
      welcomeMessage = "Good Evening";
    }
    String imageString =
        Theme.of(context).colorScheme.brightness == Brightness.dark ? "assets/dg4x.png" : "assets/lg4x.png";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            tournaments = fetchTeamTournaments(loadTeamPreview(prefs.getString("savedTeam")).teamID, seasons[0].vrcId);
          });
        },
        child: CustomScrollView(
          slivers: [
            ElapseAppBar(
              title: Text(
                welcomeMessage,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              background: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 12, bottom: 20, top: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Image(image: AssetImage(imageString), height: 25),
                          Spacer(),
                          SettingsButton(callback: () {
                            setState(() {
                              tournaments = fetchTeamTournaments(
                                  loadTeamPreview(prefs.getString("savedTeam")).teamID, seasons[0].vrcId);
                            });
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const RoundedTop(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                  child: FutureBuilder(
                    future: tournaments,
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return Center(
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return Column();
                          }

                          List<TournamentPreview> teamTournaments = snapshot.data as List<TournamentPreview>;
                          teamTournaments.removeWhere((item) {
                            return item.startDate == null || item.startDate!.difference(DateTime.now()).inDays < -2;
                          });
                          if (teamTournaments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(10),
                              child: BigErrorMessage(
                                icon: Icons.emoji_events_outlined,
                                message: "No upcoming tournaments",
                                topPadding: 0,
                              ),
                            );
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
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
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
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                                          )
                                        : Container(),
                                    upcoming.endDate != null && upcoming.endDate != upcoming.startDate
                                        ? Text(" - ${DateFormat("EEE, MMM d, y").format(upcoming.endDate!)}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                            ))
                                        : Container()
                                  ],
                                ),
                                DateTime.now().compareTo(upcoming.endDate!.add(const Duration(days: 1))) <= 0 &&
                                        DateTime.now().difference(upcoming.startDate!).inDays > -1
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 18.0),
                                        child: LongButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                                                          style:
                                                              TextStyle(color: Theme.of(context).colorScheme.secondary),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          prefs.setBool("isTournamentMode", true);
                                                          print(upcoming.id);
                                                          prefs.setInt("tournamentID", upcoming.id);
                                                          myAppKey.currentState!.reloadApp();

                                                          Provider.of<TournamentModeProvider>(context, listen: false)
                                                              .setTournamentMode(true);
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          "Confirm",
                                                          style:
                                                              TextStyle(color: Theme.of(context).colorScheme.secondary),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          },
                                          text: "Tournament Mode",
                                          icon: Icons.emoji_events,
                                          gradient: true,
                                        ),
                                      )
                                    : Container(),
                              ],
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
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                          return const SizedBox.shrink();
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            print(snapshot.error);
                            return const SizedBox.shrink();
                          }
                          if (snapshot.data == null) {
                            return const SizedBox.shrink();
                          }

                          List<TournamentPreview> teamTournaments = snapshot.data as List<TournamentPreview>;
                          if (teamTournaments.length < 2) {
                            return Container();
                          }
                          teamTournaments.removeWhere((item) {
                            return item.startDate == null || item.startDate!.difference(DateTime.now()).inDays < -2;
                          });
                          List<TournamentPreview> filteredTournaments =
                              teamTournaments.length < 2 ? [] : teamTournaments.sublist(1);
                          if (filteredTournaments.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Upcoming",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Column(
                                children: filteredTournaments.map(
                                  (e) {
                                    return TournamentPreviewWidget(tournamentPreview: e);
                                  },
                                ).toList(),
                              )
                            ],
                          );
                      }
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
