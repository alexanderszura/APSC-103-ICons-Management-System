import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';

abstract class FirebaseHandler {

  static final db = FirebaseDatabase.instance;

  static List<String> itemNames = [], urlNames = [];

  static Future<void> init() async {
    List<String> names, urls;
    (names, urls) = await _loadImages();

    itemNames = names;
    urlNames = urls;

    if (itemNames.length != urlNames.length) {
      print("Item Url Length Missmatch!");
    }

    if (names.isEmpty) {
      addItem("Multimeter", "https://upload.wikimedia.org/wikipedia/commons/2/26/Mm6000_Klein_Tools_Multimeter.png");
    }

    await User.loadBans();
  }

  static Future<List<String>?> getBannedIDs() async {
    final event = await db.ref("banned_ids").once(DatabaseEventType.value);

    return event.snapshot.children
      .map((e) => e.value as String)
      .toList();
  }

  static Future<bool> addItem(String name, String url) async {
    bool success = true;

    itemNames.add(name);
    urlNames .add(url );

    final nameRef = db.ref("items/names").push();
    final urlRef  = db.ref("items/urls") .push();

    await nameRef.set(name).catchError((error) => success = false);
    await urlRef .set(url ).catchError((error) => success = false);

    return success;
  }

  static Future<(List<String>, List<String>)> _loadImages() async {
    final nameEvent = await db.ref("items/names").once(DatabaseEventType.value);
  final urlEvent  = await db.ref("items/urls").once(DatabaseEventType.value);

  final names = nameEvent.snapshot.children
      .map((e) => e.value as String)
      .toList();

  final urls = urlEvent.snapshot.children
      .map((e) => e.value as String)
      .toList();

  return (names, urls);
  }

  static List<Item> loadItems() {
    List<Item> items = [];

    for (int i = 0; i < itemNames.length; i++) {
      items.add(Item(itemNames[i], urlNames[i]));
    }

    return items;
  }

  static Future<Map<String, dynamic>> getSessionData() async {
    final event = await db.ref("items_out").once(DatabaseEventType.value);

    var data = {
      "items_out": event.snapshot.value
    };

    return data;
  }

  static Future<bool> sync(Map<String, dynamic> data) async {
    bool success = true;

    for (String key in data.keys) {
      await db.ref(key)
        .set(data[key])
        .catchError((error) => success = false);
    }

    return success;
  }
}