class Match {
  List<int>? redAllianceID;
  List<int>? blueAllianceID;

  List<String>? redAllianceNum;
  List<String>? blueAllianceNum;

  int? redScore;
  int? blueScore;

  num roundNum;
  int gameNum;
  int instance;
  String gameName;

  String? fieldName;

  DateTime? scheduledTime;
  DateTime? adjustedScheduledTime;
  DateTime? startedTime;

  Match({
    this.redAllianceID,
    this.blueAllianceID,
    this.redAllianceNum,
    this.blueAllianceNum,
    required this.gameNum,
    required this.roundNum,
    required this.gameName,
    required this.instance,
    this.fieldName,
    this.scheduledTime,
    this.adjustedScheduledTime,
    this.startedTime,
    this.redScore,
    this.blueScore,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    List<int> redAllianceID = [];
    List<int> blueAllianceID = [];
    int redScore = 0;

    List<String> redAllianceNum = [];
    List<String> blueAllianceNum = [];
    int blueScore = 0;

    num roundNum = json["round"] == 6 ? 2.5 : json["round"];

    List<dynamic> alliances = json["alliances"];
    if (alliances[0]["color"] == "red") {
      for (int i = 0; i < alliances[0]["teams"].length; i++) {
        redAllianceID.add(alliances[0]["teams"][i]["team"]["id"]);
        redAllianceNum.add(alliances[0]["teams"][i]["team"]["name"]);
      }
      redScore = alliances[0]["score"];
      for (int i = 0; i < alliances[1]["teams"].length; i++) {
        blueAllianceID.add(alliances[1]["teams"][i]["team"]["id"]);
        blueAllianceNum.add(alliances[1]["teams"][i]["team"]["name"]);
      }
      blueScore = alliances[1]["score"];
    } else {
      for (int i = 0; i < alliances[1]["teams"].length; i++) {
        redAllianceID.add(alliances[1]["teams"][i]["team"]["id"]);
        redAllianceNum.add(alliances[1]["teams"][i]["team"]["name"]);
      }
      redScore = alliances[1]["score"];
      for (int i = 0; i < alliances[0]["teams"].length; i++) {
        blueAllianceID.add(alliances[0]["teams"][i]["team"]["id"]);
        blueAllianceNum.add(alliances[0]["teams"][i]["team"]["name"]);
      }
      blueScore = alliances[0]["score"];
    }

    String gameName = "";
    String firstPart = json["name"].split(" ")[0];
    firstPart = firstPart == "Qualifier" ? "Q" : firstPart;
    firstPart = firstPart == "Practice " ? "P" : "$firstPart ";
    firstPart = firstPart == "Final " ? "F " : firstPart;
    String secondPart = json["name"].split(" ")[1];
    secondPart = secondPart.split("-")[0];
    secondPart = secondPart.split("#")[1];
    gameName = "$firstPart$secondPart";

    return Match(
      redAllianceID: redAllianceID,
      blueAllianceID: blueAllianceID,
      redAllianceNum: redAllianceNum,
      blueAllianceNum: blueAllianceNum,
      redScore: redScore,
      blueScore: blueScore,
      roundNum: roundNum,
      gameNum: json["matchnum"],
      instance: json["instance"],
      gameName: gameName,
      fieldName: json["field"],
      scheduledTime: DateTime.tryParse(json["scheduled"] ?? ""),
      adjustedScheduledTime: DateTime.tryParse(json["scheduled"] ?? ""),
      startedTime: DateTime.tryParse(json["started"] ?? ""),
    );
  }
}
