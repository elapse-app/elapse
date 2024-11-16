import 'package:elapse_app/classes/Miscellaneous/location.dart';
import 'package:elapse_app/classes/Tournament/award.dart';
import 'package:elapse_app/classes/Tournament/tournament.dart';
import 'package:elapse_app/screens/tournament/pages/info/all_teams.dart';
import 'package:elapse_app/screens/tournament/pages/info/award_widget.dart';
import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.tournament, required this.awards});
  final Tournament tournament;
  final List<Award> awards;

  @override
  Widget build(BuildContext context) {
    Future<bool> livestream = hasLivestream(tournament.sku);

    final String tournamentName = tournament.name;
    final Location location = tournament.location;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 23.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                  borderRadius: BorderRadius.circular(18)),
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tournament Name"),
                  SizedBox(
                    height: 5,
                  ),
                  Text(tournamentName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        padding: EdgeInsets.only(right: 10, bottom: 10)),
                    onPressed: () {
                      launchUrl(Uri.https("www.robotevents.com",
                          "/robot-competitions/vex-robotics-competition/${tournament.sku}.html"));
                    },
                    child: const Text("View on RobotEvents"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Location"),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${location.address1 ?? ""}${location.address1 != null && location.address2 != null ? "," : ""}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  location.address2 != null
                      ? Text(
                          "${location.address2 ?? ""}${location.address2 == null ? "" : ","}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Container(),
                  Text(
                    "${location.city ?? ""}, ${location.region ?? ""}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.secondary,
                        padding: EdgeInsets.only(right: 10, bottom: 10)),
                    onPressed: () {
                      MapsLauncher.launchQuery(
                          "${location.address1 ?? ""}, ${location.address2 ?? ""}, ${location.city ?? ""}, ${location.region ?? ""}, ${location.postalCode ?? ""}");
                    },
                    child: const Text("View in Maps"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text("Date"),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${DateFormat("EEE, MMM d, y").format(tournament.startDate)} ${tournament.endDate != null && tournament.endDate != tournament.startDate ? "-" : ""}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      tournament.endDate != null && tournament.endDate != tournament.startDate
                          ? Text(
                              DateFormat("EEE, MMM d, y").format(tournament.endDate!),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  FutureBuilder(
                      future: livestream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container();
                        }
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 45,
                                ),
                                const CircularProgressIndicator(),
                              ],
                            );
                          case ConnectionState.done:
                            if (snapshot.data as bool) {
                              return Column(
                                children: [
                                  const SizedBox(
                                    height: 45,
                                  ),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                        foregroundColor: Theme.of(context).colorScheme.secondary,
                                        padding: const EdgeInsets.only(right: 10, bottom: 10)),
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          "https://www.robotevents.com/robot-competitions/vex-robotics-competition/${tournament.sku}.html#webcast"));
                                    },
                                    icon: const Icon(Icons.live_tv),
                                    label: const Text(
                                      "View Livestream",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Container();
                            }
                        }
                      })
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AllTeams(
                              teams: tournament.teams,
                            )));
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(18)),
                    color: Theme.of(context).colorScheme.tertiary),
                padding: const EdgeInsets.all(18),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "All Teams",
                      style: TextStyle(fontSize: 24),
                    ),
                    Icon(Icons.arrow_forward)
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              width: double.infinity,
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.tertiary, borderRadius: BorderRadius.circular(18)),
              padding: EdgeInsets.all(18),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Awards", style: TextStyle(fontSize: 24)),
                      // Icon(Icons.arrow_forward)
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: awards.map((award) => AwardWidget(award: award)).toList(),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> hasLivestream(String sku) async {
  final response = await http
      .get(Uri.parse("https://www.robotevents.com/robot-competitions/vex-robotics-competition/$sku.html#general-info"));
  print(response.body.contains("<h4>Webcast</h4>"));
  return response.body.contains("<h4>Webcast</h4>");
}
