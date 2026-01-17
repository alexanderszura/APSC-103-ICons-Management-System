import 'dart:collection';
import 'package:icons_management_system/data/entry_error.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';

abstract class InvetoryManager {

  static HashMap<User, Item> inventory = HashMap();
  
  static EntryError? addEntry(User user, Item item, {bool force = false}) {
    if (!force) {
      if (inventory.containsKey(user)) {
        return EntryError.itemOut(user);
      }

      if (user.isBanned()) {
        return EntryError.userBanned(user);
      }
    }

    inventory[user] = item.copy().withTimeStamp();

    return null;
  }

  static Item? getUserItem(User user) => inventory[user];

  static HashMap<String, dynamic> toJSON() {
    final map = HashMap<String, List>();

    map['items_out'] = [];

    inventory.forEach((user, item) {
      Map value = {"Student_ID" : user.studentNumber, "name" : user.name, "item" : item.name};
      map['items_out']?.add(value);
    });

    return map;
  }

  static void loadJSON(Map<String, dynamic> data) async {
    if (!data.containsKey("items_out")) {
      return;
    }

    for (Map<String, dynamic> entry in data['items_out']) {
      inventory[User.create(entry["name"], entry["Student_ID"])] = Item.fromName(entry["item"])!;
    }
  }
}