import 'dart:collection';
import 'package:icons_management_system/data/entry_error.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';

abstract class InvetoryManager {

  static HashMap<User, List<Item>> inventory = HashMap();
  
  static EntryError? addEntry(User user, Item item, {bool force = false}) {
    if (!force) {
      if (inventory.containsKey(user)) {
        return EntryError.itemOut(user);
      }

      if (user.isBanned()) {
        return EntryError.userBanned(user);
      }
    }

    if (!inventory.containsKey(user)) {
      inventory[user] = [];
    }

    inventory[user]?.add(item.copy().withTimeStamp());

    return null;
  }

  static List<Item> getUserItems(User user) => inventory[user] ?? [];

  static void removeItemFromUser(User user, Item item) => inventory[user]?.remove(item);
  static void removeUser(User user) => inventory.remove(user);

  static HashMap<String, dynamic> toJSON() {
    final map = HashMap<String, List>();

    map['items_out'] = [];

    inventory.forEach((user, items) {
      Map value = {"Student_ID" : user.studentNumber, "name" : user.name, "items" : items.map((item) => item.name).toList()};
      map['items_out']?.add(value);
    });

    return map;
  }

  static void loadJSON(Map<String, dynamic> data) async {
    if (!data.containsKey("items_out")) {
      return;
    }

    for (Map<String, dynamic> entry in data['items_out']) {
      List<Item> items = [];
      for (String name in entry["items"]) {
        items.add(Item.fromName(name)!);
      }

      inventory[User.create(entry["name"], entry["Student_ID"])] = items;
    }
  }
}