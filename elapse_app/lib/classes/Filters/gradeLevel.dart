class GradeLevel {
  int id;
  String name;

  GradeLevel({
    required this.id,
    required this.name,
  });
}

List<GradeLevel> gradeLevels = [
  GradeLevel(id: 0, name: "Middle and High School"),
  GradeLevel(id: 2, name: "Middle School"),
  GradeLevel(id: 3, name: "High School"),
  GradeLevel(id: 4, name: "College"),
];