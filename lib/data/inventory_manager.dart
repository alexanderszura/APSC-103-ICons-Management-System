import 'dart:collection';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/tools/entry_error.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/data/inventory_transaction.dart';

enum StudentID {
    ALPHA("Alpha"),
    NUMERIC("Numeric"),
    ALPHA_NUMERIC("Alpha-Numeric");

    final String text;

    const StudentID(this.text);

    @override
    String toString() => text;
}

abstract class InventoryManager {
  static List<InventoryTransaction> transactions = [];

  static HashMap<User, List<Item>> inventory = HashMap();
  static HashMap<String, User>     users     = HashMap();

  static List<InventoryItem> items = [];

  static StudentID studentIDType = StudentID.NUMERIC;
  static late int minLength;
  static late int maxLength;

  static Future<void> init() async {
    items = await FirebaseHandler.loadInventory();

    int min, max;

    (min, max) = await FirebaseHandler.getIDBounds();

    minLength = min;
    maxLength = max;
  }

  static List<InventoryItem> getInventory() => items; 

  static Future<bool> addToInventory(String name, String url, int quantity) async {
    bool success = true;

    InventoryItem item = InventoryItem(name, url, quantity);
    items.add(item);

    await FirebaseHandler.pushItem(item);

    return success;
  }

  static Future<bool> updateItem(InventoryItem item, int? quantity, String? url) async {
    int index = items.indexOf(item);

    if (quantity != null) {
      items[index].quantity = quantity;
    }

    if (url != null && url.isNotEmpty) {
      items[index].url = url;
    }

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

  static void recordCheckout(User user, InventoryItem item, DateTime time) {
  transactions.add(
    InventoryTransaction(
      type: "checkout",
      itemName: item.name,
      studentId: user.studentNumber,
      userName: user.name,
      timestamp: time,
    ),
  );
}

static void recordReturn(User user, Item item, DateTime time) {
  transactions.add(
    InventoryTransaction(
      type: "return",
      itemName: item.name,
      studentId: user.studentNumber,
      userName: user.name,
      timestamp: time,
    ),
  );
}
  
  static EntryError? addEntry(User user, List<InventoryItem> items, {bool force = false}) {
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

    DateTime now = DateTime.now();
    for (InventoryItem item in items) {
      inventory[user]?.add(item.userItem().withInfo(staff: FirebaseHandler.userName ?? "No Staff", time: now));
      recordCheckout(user, item, now);
    }

    return null;
  }

  static bool isRegistered(String studentId) => users.containsKey(studentId);

  static List<Item> getUserItems(User user) => inventory[user] ?? [];

  static void removeItemFromUser(User user, Item item) {
    inventory[user]?.remove(item);
    recordReturn(user, item, DateTime.now());
  }
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

    final Map<String, dynamic> transactionMap = {};
    for (int i = 0; i< transactions.length; i++){
      transactionMap["tx_$i"]= transactions[i].toJSON();
    }


    map['items_out'] = itemsOutMap;
    map['transactions'] = transactionMap;

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
    inventory.clear();
    transactions.clear();

    if (data.containsKey("items_out") && data["items_out"] != null){
      try {
      final itemsOut = Map<String, dynamic>.from(data["items_out"]);

      for (final entry in itemsOut.entries) {
        final studentId = entry.key;
        final entryData = Map<String, dynamic>.from(entry.value);

        final List<Item> items = [];

        if (entryData.containsKey("items") && entryData["items"] != null) {
          final itemsMap = Map<String, dynamic>.from(entryData["items"]);

          for (final itemEntry in itemsMap.entries) {
            final parsed = Item.fromJSON(Map<String, dynamic>.from(itemEntry.value),);
            

            if (parsed != null) {
              items.add(parsed);
            }
          }
        }

        final user = getUser(studentId);
        if(user !=null){
          inventory[user]= items;
        }
      }
    } catch (e) {
      print("Unable to parse items_out...");
      print(e);
    }
  }

  if (data.containsKey("transactions") && data[transactions] !=null){
    try{
      final txMap = Map<String, dynamic>.from(data["transactions"]);
      
      for (final entry in txMap.entries){
        final parsed = InventoryTransaction.fromJSON(Map<String, dynamic>.from(entry.value),);
        if (parsed !=null){
          transactions.add(parsed);
        }
      }
    } catch (e){
      print("Unable to parse transactions...");
      print(e);
    }
  }
}
}