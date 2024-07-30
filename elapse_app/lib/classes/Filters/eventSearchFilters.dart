class EventSearchFilters {
  int seasonID;
  String eventName = "";
  String regionID = "";
  String gradeLevelID = "";
  String levelClassID = "";
  String startDate = "";
  String endDate = "";

  EventSearchFilters({
    required this.seasonID,
    required this.eventName,
    this.regionID = "",
    this.gradeLevelID = "",
    this.levelClassID = "",
    this.startDate = "",
    this.endDate = "",
  });
}
