import 'package:icons_management_system/tools/date_from.dart';

class Item {
  String name;
  DateTime? time;
  
  Item(this.name);

  String getName() => name;

  Item withTimestamp({DateTime? time}) {
    time ??= DateTime.now();
    this.time = time;

    return this;
  }

  Item copy() => Item(name);

  DateTime? getTimestamp() => time;

  static Item? fromJSON(Map<String, dynamic> data) {
    try {
      return Item(
        data['item'],
      ).withTimestamp(time: TimeHelper.fromString(data['time']));
    } catch (e) {
      print("Unable to parse data...");
      print(data);
      print(e);

      return null;
    }
  }

  Map<String, dynamic> toJSON(bool isPlayer) => {
    "item": name,
    "time": TimeHelper.shorten(time ?? DateTime.now())
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}