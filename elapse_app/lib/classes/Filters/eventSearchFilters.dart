class EventSearchFilters {
  int seasonID;
  String? eventName;
  int? regionID;
  int? gradeLevelID;
  int? levelClassID;
  String? startDate;
  String? endDate;

  EventSearchFilters({
    required this.seasonID,
    this.eventName,
    this.gradeLevelID,
    this.levelClassID,
    this.startDate,
    this.endDate,
  });
}
