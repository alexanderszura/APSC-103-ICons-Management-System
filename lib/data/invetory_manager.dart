import 'dart:collection';
import 'package:icons_management_system/tools/entry_error.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/tools/date_from.dart';

abstract class InvetoryManager {

  static HashMap<User, List<Item>> inventory = HashMap();
  static HashMap<String, User>     users     = HashMap();

  static User createUser(String name, String studentNumber, String email) {
    final user = User.create(name, studentNumber, email);
    users[studentNumber] = user;

    return user;
  }
  
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

    inventory[user]?.add(item.copy().withTimestamp());

    return null;
  }

  static bool isRegistered(String studentId) => users.containsKey(studentId);

  static List<Item> getUserItems(User user) => inventory[user] ?? [];

  static void removeItemFromUser(User user, Item item) => inventory[user]?.remove(item);
  static void removeUserItemData(User user) => inventory.remove(user);

  static User? getUser(String studentNumber) => users[studentNumber];

  static HashMap<String, dynamic> toJSON() {
    final map = HashMap<String, List>();

    map['items_out'] = [];

    inventory.forEach((user, items) {
      Map value = {"student_id" : user.studentNumber, "items" : items.map((item) => item.toJSON(true)).toList()};
      map['items_out']?.add(value);
    });

    return map;
  }

  static void loadUserData(List<Map<String, dynamic>> data) async {
    for (var entry in data) {
      createUser(entry["name"], entry["student_id"], entry["email"]);
    }
  }

  static void loadJSON(Map<String, dynamic> data) async {
    if (!data.containsKey("items_out") || data["items_out"] == null) {
      return;
    }

    try {
      for (var entry in data["items_out"]) {
        List<Item> items = [];
        
        for (var itemData in entry["items"]) {
          try {
            String itemName = itemData["item"];
            Item? item = Item.fromName(itemName)?.withTimestamp(
              time: TimeHelper.fromString(itemData["time"])
            );

            if (item != null) {
              items.add(item);
            }

          } catch (e) {
            print("Error parsing item data: $e");
            print("Item data: $itemData");
          }
        }

        User? user = getUser(entry["student_id"]);

        if (user != null) {
          inventory[user] = items;
        } else {
          print("Couldn't find user inventory to store items: ${items.join(', ')}");
        }
      }
    } catch (e) {
      print("Error loading JSON data: $e");
      print("Data: $data");
      print(e);
    }
  }
}