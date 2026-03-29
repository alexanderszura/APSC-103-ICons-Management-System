class InventoryTransaction {
  final String type; // "checkout" or "return"
  final String itemName;
  final String studentId;
  final String userName;
  final DateTime timestamp;

  InventoryTransaction({
    required this.type,
    required this.itemName,
    required this.studentId,
    required this.userName,
    required this.timestamp,
  });

  Map<String, dynamic> toJSON() {
    return {
      "type": type,
      "item_name": itemName,
      "student_id": studentId,
      "user_name": userName,
      "timestamp": timestamp.toIso8601String(),
    };
  }

  static InventoryTransaction? fromJSON(Map<String, dynamic> data) {
    try {
      return InventoryTransaction(
        type: data["type"],
        itemName: data["item_name"],
        studentId: data["student_id"],
        userName: data["user_name"],
        timestamp: DateTime.parse(data["timestamp"]),
      );
    } catch (e) {
      print("Unable to parse transaction...");
      print(data);
      print(e);
      return null;
    }
  }
}