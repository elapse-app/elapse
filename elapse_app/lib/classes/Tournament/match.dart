class Match {
  List<int> redAllianceID;
  List<int> blueAllianceID;

  List<String> redAllianceNum;
  List<String> blueAllianceNum;

  int? redScore;
  int? blueScore;

  int roundNum;
  int gameNum;
  String gameName;

  String fieldName;

  DateTime originalTime;
  DateTime adjustedTime;

  Match({
    required this.redAllianceID,
    required this.blueAllianceID,
    required this.redAllianceNum,
    required this.blueAllianceNum,
    required this.gameNum,
    required this.roundNum,
    required this.gameName,
    required this.fieldName,
    required this.originalTime,
    required this.adjustedTime,
    this.redScore,
    this.blueScore,
  });
}
