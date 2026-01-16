class User {
  String name;
  int studentNumber;

  bool banned = false;
  
  User(this.name, this.studentNumber);

  String getName() => name;
  int getStudentNumber() => studentNumber;

  void banUser() => banned = true;
  void unbanUser() => banned = false;

  bool isBanned() => banned;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.studentNumber == studentNumber;
  }

  @override
  int get hashCode => studentNumber.hashCode;
}