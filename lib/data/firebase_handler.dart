import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';

abstract class FirebaseHandler {

  static final db = FirebaseDatabase.instance;

  static List<Item> items = [];

  static Future<void> init() async {
    items = await _loadImages();

    await User.loadBans();
  }

  static Future<List<String>?> getBannedIDs() async {
    final event = await db.ref("banned_ids").once(DatabaseEventType.value);

    return event.snapshot.children
      .map((e) => e.value as String)
      .toList();
  }

  static Future<bool> registerUser(User user) async {
    bool success = true;

    final ref = db.ref("users").push();

    await ref.set(user.toJSON()).catchError((error) => success = false);

    return success;
  }

  static Future<bool> addItem(String name, String url) async {
    bool success = true;

    Item item = Item(name, url);
    items.add(item);

    final ref = db.ref("items").push();

    await ref.set(item.toJSON(false)).catchError((error) => success = false);

    return success;
  }

  static Future<bool> removeItem(Item item) async {
    bool success = true;

    final ref = db.ref("items");

    items.remove(item);

    await ref.set(items).catchError((error) => success = false);

    return success;
  }

  static Future<List<Item>> _loadImages() async {
    final event = await db.ref("items").once(DatabaseEventType.value);

    final data = event.snapshot.children
      .map((e) {
        final value = e.value;
        if (value is Map) {
          return Item.fromJSON(Map<String, dynamic>.from(value));
        }
        return null;
      })
      .whereType<Item>()
      .toList();

    return data;
  }

  static List<Item> getItems() => items;

  static Future<List<Map<String, dynamic>>> getUserData() async {
    final event = await db.ref("users").once(DatabaseEventType.value);

    final data = event.snapshot.children
      .map((e) {
        final value = e.value;
        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
        return null;
      })
      .whereType<Map<String, dynamic>>()
      .toList();

    return data;
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