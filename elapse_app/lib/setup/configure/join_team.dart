import 'package:elapse_app/setup/configure/theme_setup.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';
import 'package:flutter/material.dart';
import 'package:elapse_app/classes/Team/teamPreview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elapse_app/main.dart';
import 'package:elapse_app/setup/signup/enter_details.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key,});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  _JoinTeamPageState();
  final TextEditingController _teamController = TextEditingController();
  Future<List<TeamPreview>>? teamSearch;
  String searchQuery = "";
  String buttonLabel = "Search";
  TeamPreview? selectedTeam;

  void searchTeam() async {
    setState(() {
      searchQuery = _teamController.text;
      teamSearch = fetchTeamPreview(searchQuery);
    });

    final teams = await teamSearch;
    if (teams != null && teams.isNotEmpty) {
      setState(() {
        selectedTeam = teams.first;
        buttonLabel = "Confirm";
      });
    } else {
      setState(() {
        selectedTeam = null;
        buttonLabel = "Search";
      });
    }
  }

  void saveTeam(TeamPreview team) {
    prefs.setString("savedTeam",
        '{"teamID": ${team.teamID}, "teamNumber": "${team.teamNumber}"}');
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EnterDetailsPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 191, 231, 237),
      appBar: PreferredSize(
        preferredSize: MediaQuery.of(context).size * 0.07,
        child: AppBar(
          backgroundColor: Color.fromARGB(255, 191, 231, 237),
          title: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EnterDetailsPage()),
              );
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back),
                SizedBox(width: 12),
                Text('Setup',
                  style: TextStyle(
                fontSize: 24,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: [
              SizedBox(height: 46),
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Team details',
                      style: TextStyle(
                        fontFamily: "Manrope",
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: const Color.fromARGB(255, 12, 77, 86),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Get personalized info for your team',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                      color: Color.fromARGB(255, 117, 117, 117),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                  child: TextFormField(
                  controller: _teamController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 187, 51, 51),
                        width: 1.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 187, 51, 51),
                        width: 2.0,
                      ),
                    ),
                    labelText: 'Team Number',
                    labelStyle: TextStyle(
                    color: Color.fromARGB(255, 73, 69, 79),
                    fontWeight: FontWeight.w400,
                    fontFamily: "Manrope",
                    fontSize: 16,
                  ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<TeamPreview>>(
                future: teamSearch,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Text('Press confirm to continue');
                  } else {
                    return Text('');
                  }
                },
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.fromLTRB(23, 0, 23, 0),
                child: SizedBox(
                  height: 59.0,
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 76, 81, 175),
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 191, 231, 237),
                        width: 1.0,
                      ),
                    ),
                    onPressed: () {
                      if (buttonLabel == "Search") {
                        searchTeam();
                      } else if (buttonLabel == "Confirm" && selectedTeam != null) {
                        saveTeam(selectedTeam!);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ThemeSetup(),
                            ),
                          );
                      }
                    },
                    child: Text(
                      buttonLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "Manrope",
                        fontSize: 16,
                        color: Color.fromARGB(255, 12, 77, 86),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height:38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}