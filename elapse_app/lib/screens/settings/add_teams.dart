import 'dart:convert';

import 'package:elapse_app/screens/widgets/big_error_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../classes/Team/teamPreview.dart';
import '../../main.dart';
import '../widgets/app_bar.dart';
import '../widgets/custom_tab_bar.dart';

class AddTeamPage extends StatefulWidget {
  const AddTeamPage({super.key});

  @override
  State<AddTeamPage> createState() => _AddTeamPageState();
}

class _AddTeamPageState extends State<AddTeamPage> {
  String searchQuery = "";
  Future<List<TeamPreview>>? searchResults;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const ElapseAppBar(
            title: Text("Add teams", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
            backNavigation: true,
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverHeaderDelegate(
              maxHeight: 60,
              minHeight: 60,
              child: Hero(
                tag: "top",
                child: Stack(
                  children: [
                    Container(
                      color: Theme.of(context).colorScheme.primary,
                      height: 60,
                    ),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child: TextField(
                          textInputAction: TextInputAction.search,
                          onSubmitted: (query) {
                            setState(() {
                              searchQuery = query;
                              searchResults = fetchTeamPreview(query);
                            });
                          },
                          cursorColor: Theme.of(context).colorScheme.secondary,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.search),
                            hintText: "Search teams",
                            border: InputBorder.none,
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            sliver: FutureBuilder(
                future: searchResults,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return const SliverToBoxAdapter(child: BigErrorMessage(icon: Icons.search, message: "Search for teams to add"));
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return const SliverToBoxAdapter(child: BigErrorMessage(icon: Icons.search_off, message: "Unable to fetch teams"));
                      }

                      List<TeamPreview> teams = (snapshot.data as List<TeamPreview>).toSet().toList();
                      if (teams.isEmpty) {
                        return const SliverToBoxAdapter(child: BigErrorMessage(icon: Icons.search_off, message: "No teams found"));
                      }

                      return SliverList(
                          delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final team = teams[index];
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            List<TeamPreview> savedTeams = getSavedTeams();

                                            if (savedTeams.contains(team)) {
                                              savedTeams.remove(team);
                                            } else {
                                              savedTeams.add(team);
                                            }

                                            prefs.setString("savedTeam", jsonEncode(savedTeams[0].toJson()));
                                            prefs.setStringList("savedTeams", savedTeams.sublist(1).map((e) => jsonEncode(e.toJson())).toList());
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: Flex(
                                                direction: Axis.horizontal,
                                                children: [
                                                  Flexible(
                                                    flex: 6,
                                                    fit: FlexFit.tight,
                                                    child: Text(team.teamNumber,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 40,
                                                            height: 1,
                                                            letterSpacing: -1.5,
                                                            fontWeight: FontWeight.w400,
                                                            color: Theme.of(context).colorScheme.onSurface)),
                                                  ),
                                                  Flexible(
                                                    flex: 7,
                                                    fit: FlexFit.tight,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      children: [
                                                        Text(team.teamName ?? "",
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                            )),
                                                        Text(
                                                            '${team.location?.city ?? ""}${team.location?.city != null ? "," : ""} ${team.location?.region ?? ""}',
                                                            textAlign: TextAlign.end,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withOpacity(0.65),
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                  Flexible(
                                                    flex: 2,
                                                    fit: FlexFit.tight,
                                                    child: Icon(
                                                      getSavedTeams().contains(team) ? Icons.check : Icons.add,
                                                    ),
                                                  )
                                                ]
                                            ),
                                          ),
                                        ),
                                        index != teams.length - 1
                                            ? Divider(
                                          height: 3,
                                          color: Theme.of(context).colorScheme.surfaceDim,
                                        )
                                            : const SizedBox.shrink(),
                                      ]
                                    );
                              },
                            childCount: teams.length,
                          ),
                      );
                  }
                }
            )
          )
        ]
      ),
    );
  }
}

List<TeamPreview> getSavedTeams() {
  final String savedTeam = prefs.getString("savedTeam") ?? "";
  final parsed = jsonDecode(savedTeam);
  List<TeamPreview> savedTeamsList = [TeamPreview(teamID: parsed["teamID"], teamNumber: parsed["teamNumber"])];

  final List<String> savedTeams = prefs.getStringList("savedTeams") ?? [];
  savedTeamsList.addAll(savedTeams.map((e) => TeamPreview(teamID: jsonDecode(e)["teamID"], teamNumber: jsonDecode(e)["teamNumber"])));

  return savedTeamsList;
}