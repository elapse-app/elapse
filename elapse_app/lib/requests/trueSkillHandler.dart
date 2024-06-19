import 'dart:convert';

import 'package:elapse_app/classes/Team/vdaStats.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<VDAStats>> getTrueSkillData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? vdaData = prefs.getString("vdaData");
  final String? expiryDate = prefs.getString("vdaExpiry");
  List<dynamic> parsed = [];

  if (vdaData == null ||
      expiryDate == null ||
      DateTime.parse(expiryDate).isBefore(DateTime.now())) {
    final response = await http.get(
      Uri.parse("https://vrc-data-analysis.com/v1/allteams"),
    );
    prefs.setString("vdaData", response.body);
    prefs.setString("vdaExpiry",
        DateTime.now().add(const Duration(minutes: 20)).toString());
    parsed = jsonDecode(response.body) as List;
  } else {
    parsed = jsonDecode(vdaData) as List;
  }

  List<VDAStats> vdaStats =
      parsed.map<VDAStats>((json) => VDAStats.fromJson(json)).toList();
  return vdaStats;
}

Future<VDAStats> getTrueSkillDataForTeam(int teamId) async {
  final response = await getTrueSkillData();
  return response.firstWhere((element) => element.id == teamId);
}
