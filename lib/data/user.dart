import 'package:icons_management_system/data/firebase_handler.dart';

class User {

  static List<String>? bannedIDs;

  String name;
  String studentNumber;
  String email;

  bool banned = false;
  int strikes = 0;
  
  User._(this.name, this.studentNumber, this.email);

  String getName() => name;
  String getStudentNumber() => studentNumber;
  String getEmail() => email;

  void banUser() => banned = true;
  void unbanUser() => banned = false;

  User withBanStatus(bool ban) {
    ban ? banUser() : unbanUser();
    return this;
  }

  User withStrikes(int s) {
    strikes = s;
    if (strikes >= 2) banUser();
    return this;
  }

  bool isBanned() => banned;

  Map<String, dynamic> toJSON() => {
    "name": name,
    "student_id": studentNumber,
    "email": email,
    "strikes": strikes,
  };

  static Future<void> loadBans() async => bannedIDs ??= await FirebaseHandler.getBannedIDs();

  static User create(String name, String studentNumber, String email, {int strikes = 0}) {
    bool isBanned = (bannedIDs ?? []).contains(studentNumber);

    return User._(name, studentNumber, email).withStrikes(strikes).withBanStatus(isBanned || strikes >= 2);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.studentNumber == studentNumber;
  }

  @override
  int get hashCode => studentNumber.hashCode;

  @override
  String toString() {
    return "Name: $name, ID: $studentNumber";
  }
}