import 'package:icons_management_system/data/file_handler.dart';

class User {

  static List<String>? bannedIDs;

  String name;
  String studentNumber;

  bool banned = false;
  
  User._(this.name, this.studentNumber);

  String getName() => name;
  String getStudentNumber() => studentNumber;

  void banUser() => banned = true;
  void unbanUser() => banned = false;

  User withBanStatus(bool ban) {
    ban ? banUser() : unbanUser();
    return this;
  }

  bool isBanned() => banned;

  static Future<User> create(String name, String studentNumber) async {
    bannedIDs ??= await FileHandler.getBannedIDs();

    bool isBanned = bannedIDs!.contains(studentNumber);

    return User._(name, studentNumber).withBanStatus(isBanned);
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