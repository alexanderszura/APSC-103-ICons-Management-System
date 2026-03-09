import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:flutter/foundation.dart' as foundation;

abstract class FirebaseHandler {

  static final db = FirebaseDatabase.instance.ref(
    foundation.kDebugMode ? "development" : "production"
  );

  static Future<bool> pushItem(InventoryItem item) async {
    bool success = true;

    final ref = db.child("items").push();

    await ref.set(item.toJSON()).catchError((error) => success = false);

    return success;
  }

  static bool isLoggedIn() => FirebaseAuth.instance.currentUser != null;

  static Future<bool> login() async {
    if (isLoggedIn()) {
      return true;
    }

    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

      final microsoftProvider = MicrosoftAuthProvider();

      microsoftProvider.setCustomParameters({
        'tenant': 'd61ecb3b-38b1-42d5-82c4-efb2838b925c'
      });

      final userCredential = await FirebaseAuth.instance.signInWithPopup(microsoftProvider);

      return userCredential.user != null;
    } catch (e) {
      print("Sign-In Error: $e");
      return false;
    }
  }

  static Future<void> logout() async => await FirebaseAuth.instance.signOut();

  static Future<List<String>?> getBannedIDs() async {
    final event = await db.child("banned_ids").once(DatabaseEventType.value);

    return event.snapshot.children
      .map((e) => e.value as String)
      .toList();
  }

  static Future<bool> registerUser(User user) async {
    bool success = true;

    final ref = db.child("users").push();

    await ref.set(user.toJSON()).catchError((error) => success = false);

    return success;
  }

  static Future<List<InventoryItem>> loadInventory() async {
    final event = await db.child("items").once(DatabaseEventType.value);

    final data = event.snapshot.children
      .map((e) {
        final value = e.value;
        if (value is Map) {
          return InventoryItem.fromJSON(Map<String, dynamic>.from(value));
        }
        return null;
      })
      .whereType<InventoryItem>()
      .toList();

    return data;
  }

  static Future<bool> updateInventory(List<InventoryItem> items) async {
    bool success = true;

    final ref = db.child("items");

    await ref.set(items).catchError((error) => success = false);

    return success;
  }

  static Future<List<Map<String, dynamic>>> getUserData() async {
    final event = await db.child("users").once(DatabaseEventType.value);

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
    final event = await db.child("items_out").once(DatabaseEventType.value);

    var data = {
      "items_out": event.snapshot.value
    };

    return data;
  }

  static Future<bool> sync(Map<String, dynamic> data) async {
    bool success = true;

    for (String key in data.keys) {
      await db.child(key)
        .set(data[key])
        .catchError((error) => success = false);
    }

    return success;
  }
}