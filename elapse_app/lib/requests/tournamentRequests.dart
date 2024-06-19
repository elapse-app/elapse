import 'package:elapse_app/classes/Filters/eventSearchFilters.dart';
// import 'package:elapse_app/classes/Tournament/tournamentPreview.dart';
import 'package:chaleno/chaleno.dart';

Future<void> getTournaments(EventSearchFilters filters) async {
  print("Loading ");
  final parser = await Chaleno().load(
      // "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=&eventType=&name${filters.eventName}=&grade_level_id=${filters.gradeLevelID}&level_class_id=${filters.levelClassID}&from_date=${filters.startDate}&to_date=${filters.endDate}&event_region=${filters.endDate}&city=&distance=30");
      "https://www.robotevents.com/robot-competitions/vex-robotics-competition?country_id=*&seasonId=&eventType=&name=&grade_level_id=&level_class_id=&from_date=2024-06-11&to_date=&event_region=2504&city=&distance=30");

  print("Loaded");
  List<Result> nameResults = parser!.querySelectorAll(
      '#competitions-app > div.col-sm-8.results > div > div > p');
  List<String?> tournamentNames =
      nameResults.map((e) => e.text?.trim()).toList();

  Result result = parser.querySelector(
      '#competitions-app > div.col-sm-8.results > div:nth-child(1) > div > div > div:nth-child(1) > p');

  // List<Result> dateResults = parser!.querySelectorAll(
  //     '#competitions-app > div.col-sm-8.results > div:nth-child(1) > div > div > div:nth-child(1) > p:nth-child(4)');
  // List<String?> tournamentDates = dateResults.map((e) => e.text).toList();

  // List<Result> locationResults = parser.querySelectorAll(
  //     '#competitions-app > div.col-sm-8.results > div > div > div > div:nth-child(2) > p:nth-child(3)');
  // List<String?> tournamentLocations =
  //     locationResults.map((e) => e.text).toList();

  // List<Result> regionResults = parser.querySelectorAll(
  //     '#competitions-app > div.col-sm-8.results > div > div > div > div:nth-child(1) > p:nth-child(4)');
  // List<String?> tournamentRegions = locationResults.map((e) => e.text).toList();

  // List<Result> SKUResults = parser.querySelectorAll(
  //     '#competitions-app > div.col-sm-8.results > div > div > div > div:nth-child(2) > p:nth-child(1)');
  // List<String?> tournamentSKUs = locationResults.map((e) => e.text).toList();

  print(result.text);
}
