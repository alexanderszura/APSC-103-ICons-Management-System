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
}