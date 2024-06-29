String twelveHour(String time) {
  try {
    List<String> timeSplit = time.split(":");
    int hour = int.parse(timeSplit[0]);
    int minute = int.parse(timeSplit[1]);
    String suffix = "AM";
    if (hour > 12) {
      hour -= 12;
      suffix = "PM";
    }
    String adjustedHour = hour == 0 ? "00" : hour.toString();
    String adjustedMinute = minute == 0 ? "00" : minute.toString();
    return "$adjustedHour:$adjustedMinute $suffix";
  } catch (e) {
    return time;
  }
}
