import 'dart:convert';

class ElapseUser {
  // User Class
  String? uid;
  String? email;
  String? fname;
  String? lname;
  // Team of the Team Group
  String? teamNumber;
  bool? verified;

  // Members of the Team Group
  List<String> groupID = [];

  // FirebaseAuth auth = FirebaseAuth.instance;

  ElapseUser({
    required this.uid,
    required this.email,
    this.fname,
    this.lname,
    this.teamNumber,
    List<String>? groupID,
    this.verified,
  }) : groupID = groupID ?? [];

  factory ElapseUser.fromJson(Map<String, dynamic> json) {
    return ElapseUser(
      uid: json["uid"],
      email: json["email"],
      fname: json["first-name"],
      lname: json["last-name"],
      teamNumber: json["team-number"],
      groupID: json["group-id"] != null
          ? (json["group-id"] as List).map((e) => e.toString()).toList()
          : [],
      verified: json["verified"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "email": email,
      "first-name": fname,
      "last-name": lname,
      "team-number": teamNumber,
      "group-id": groupID,
      "verified": verified,
    };
  }
}

ElapseUser elapseUserDecode(String json) {
  Map<String, dynamic> map = jsonDecode(json);
  return ElapseUser(
    uid: map["uid"],
    email: map["email"],
    fname: map["firstName"],
    lname: map["lastName"],
    teamNumber: map["team"]["teamNumber"],
    groupID: (map["groupId"] as List).map((e) => e.toString()).toList(),
    verified: map["verified"],
  );
}
