import 'dart:convert';

import '../../main.dart';
import '../Team/teamPreview.dart';

class GradeLevel {
  int id;
  String name;

  GradeLevel({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GradeLevel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

Map<String, GradeLevel> gradeLevels = Map.fromEntries([
  MapEntry("Middle School", GradeLevel(id: 2, name: "Middle School")),
  MapEntry("High School", GradeLevel(id: 3, name: "High School")),
  MapEntry("College", GradeLevel(id: 4, name: "College"))
]);

GradeLevel getGradeLevel(String? grade) {
  if (grade == "Main Team") {
    return gradeLevels[
            jsonDecode(prefs.getString("savedTeam") ?? "")["grade"]] ??
        GradeLevel(id: 3, name: "High School");
  }
  return gradeLevels[grade] ?? gradeLevels["High School"]!;
}
