import 'dart:collection';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/tools/entry_error.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';

abstract class InventoryManager {

  static HashMap<User, List<Item>> inventory = HashMap();
  static HashMap<String, User>     users     = HashMap();

  static List<InventoryItem> items = [];

  static Future<void> init() async => items = await FirebaseHandler.loadInventory();

  static List<InventoryItem> getInventory() => items; 

  static Future<bool> addToInventory(String name, String url, int quantity) async {
    bool success = true;

    InventoryItem item = InventoryItem(name, url, quantity);
    items.add(item);

    await FirebaseHandler.pushItem(item);

    return success;
  }

  static Future<bool> updateQuantity(InventoryItem item, int quantity) async {
    items[items.indexOf(item)].quantity = quantity;

    return await FirebaseHandler.updateInventory(items);
  }

  static Future<bool> removeItemFromInventory(InventoryItem item) async {
    items.remove(item);

    return await FirebaseHandler.updateInventory(items);
  }

  static User createUser(String name, String studentNumber, String email, {int strikes = 0}) {
    final user = User.create(name, studentNumber, email, strikes: strikes);
    users[studentNumber] = user;

    return user;
  }
  
  static EntryError? addEntry(User user, InventoryItem item, {bool force = false}) {
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

    inventory[user]?.add(item.userItem().withTimestamp());

    return null;
  }

  static bool isRegistered(String studentId) => users.containsKey(studentId);

  static List<Item> getUserItems(User user) => inventory[user] ?? [];

  static void removeItemFromUser(User user, Item item) => inventory[user]?.remove(item);
  static void removeUserItemData(User user) => inventory.remove(user);

  static User? getUser(String studentNumber) => users[studentNumber];

  static Map<String, dynamic> toJSON() {
    final Map<String, dynamic> map = {};

    final Map<String, dynamic> itemsOutMap = {};

    inventory.forEach((user, items) {
      final studentId = user.studentNumber;

      final Map<String, dynamic> itemMap = {};

      for (int i = 0; i < items.length; i++) {
        itemMap["item_$i"] = items[i].toJSON(true);
      }

      itemsOutMap[studentId] = {
        "student_id": studentId,
        "items": itemMap,
      };
    });

    map['items_out'] = itemsOutMap;

    return map;
  }

  // Return how many of a specific inventory item are currently out (checked out by users)
  static int amountOutFor(InventoryItem item) {
    var count = 0;
    inventory.values.forEach((list) {
      for (final it in list) {
        if (it.name == item.name) count++;
      }
    });
    return count;
  }

  static int amountOnHandFor(InventoryItem item) {
    final out = amountOutFor(item);
    return item.quantity - out;
  }

  static void loadUserData(List<Map<String, dynamic>> data) async {
    for (var entry in data) {
      int strikes = 0;
      if (entry.containsKey('strikes')) {
        try {
          strikes = entry['strikes'] is int ? entry['strikes'] : int.parse(entry['strikes'].toString());
        } catch (_) {}
      }

      createUser(entry["name"], entry["student_id"], entry["email"], strikes: strikes);
    }
  }

  static void loadJSON(Map<String, dynamic> data) {
    if (!data.containsKey("items_out") || data["items_out"] == null) {
      return;
    }

    try {
      final itemsOut = Map<String, dynamic>.from(data["items_out"]);

      for (final entry in itemsOut.entries) {
        final studentId = entry.key;
        final entryData = Map<String, dynamic>.from(entry.value);

        final List<Item> items = [];

        if (entryData.containsKey("items") && entryData["items"] != null) {
          final itemsMap = Map<String, dynamic>.from(entryData["items"]);

          for (final itemEntry in itemsMap.entries) {
            final itemData = Map<String, dynamic>.from(itemEntry.value);

            Item? item = Item.fromJSON(itemData);

            if (item != null) {
              items.add(item);
            }
          }
        }

        User? user = getUser(studentId);

        if (user != null) {
          inventory[user] = items;
        } else {
          print("Couldn't find user $studentId for items: $items");
        }
      }
    } catch (e) {
      print("Error loading JSON data: $e");
      print("Data: $data");
    }
  }
}