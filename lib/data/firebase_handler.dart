import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:flutter/foundation.dart' as foundation;

abstract class FirebaseHandler {

  FirebaseHandler._();

  static final db = FirebaseDatabase.instance.ref(
    foundation.kDebugMode ? "development" : "production"
  );

  static String? get userName => FirebaseAuth.instance.currentUser?.displayName;

  static Future<bool> pushItem(InventoryItem item) async {
    try {
      final ref = db.child("items").child(item.name);

      await ref.set(item.toJSON());

      return true;
    } catch (e) {
      print("Push Item Error: $e");
      return false;
    }
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
      print(FirebaseAuth.instance.currentUser?.uid);
      print(FirebaseAuth.instance.currentUser?.email);
      return userCredential.user != null;
    } catch (e) {
      print("Sign-In Error: $e");
      return false;
    }
  }

  static Future<void> logout() async => await FirebaseAuth.instance.signOut();

  static Future<List<String>> getBannedIDs() async {
    final event = await db.child("banned_ids").once(DatabaseEventType.value);

    if (event.snapshot.value == null) return [];

    final map = Map<String, dynamic>.from(event.snapshot.value as Map);

    return map.keys.toList();
  }

  static Future<bool> registerUser(User user) async {
    try {
      final ref = db.child("users").child(user.studentNumber);

      await ref.set({
        ...user.toJSON(),
        "strikes": 0,
      });

      return true;
    } catch (e) {
      print("Register Error: $e");
      return false;
    }
  }

  static Future<List<InventoryItem>> loadInventory() async {
    final event = await db.child("items").once(DatabaseEventType.value);

    if (event.snapshot.value == null) return [];

    final map = Map<String, dynamic>.from(event.snapshot.value as Map);

    return map.entries.map((entry) {
      return InventoryItem.fromJSON(
        Map<String, dynamic>.from(entry.value),
      );
    })
    .where((item) => item != null)
    .cast<InventoryItem>()
    .toList();
  }

  static Future<bool> updateInventory(List<InventoryItem> items) async {
    bool success = true;

    final ref = db.child("items");

    // Store inventory as a map keyed by item name to avoid numeric array keys
    final Map<String, dynamic> map = {};
    for (final it in items) {
      map[it.name] = it.toJSON();
    }

    await ref.set(map).catchError((error) => success = false);

    return success;
  }

  static Future<List<Map<String, dynamic>>> getUserData() async {
    final event = await db.child("users").once(DatabaseEventType.value);

    if (event.snapshot.value == null) return [];

    final map = Map<String, dynamic>.from(event.snapshot.value as Map);

    return map.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  static Future<Map<String, dynamic>> getSessionData() async {
    final itemsOutEvent = await db.child("items_out").once(DatabaseEventType.value);
    final transactionsEvent = await db.child("transactions").once(DatabaseEventType.value);


    return {
      "items_out": itemsOutEvent.snapshot.value,
      "transactions": transactionsEvent.snapshot.value,
    };
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

  static Future<bool> setUserStrikes(String studentNumber, int strikes) async {
    try {
      final userRef = db.child('users').child(studentNumber);

      await userRef.update({'strikes': strikes});

      final bannedRef = db.child('banned_ids').child(studentNumber);

      if (strikes >= 2) {
        await bannedRef.set(true);
      } else {
        await bannedRef.remove();
      }

      return true;
    } catch (e) {
      print("Strike Error: $e");
      return false;
    }
  }

  static Future<bool> setStudentIdType(StudentID type) async {
    try {
      final studentIdTypeRef = db.child("settings/student_id_type");

      await studentIdTypeRef.set(type.toString());

      return true;
    } catch (e) {
      print("Student Id Type Error: $e");
      return false;
    }
  }

  static Future<StudentID> getStudentIdType() async {
    try {
      final studentIdTypeRef = db.child("settings/student_id_type");

      final event = await studentIdTypeRef.once(DatabaseEventType.value);

      final snapshot = event.snapshot;

      if (!snapshot.exists) {
        await setStudentIdType(StudentID.NUMERIC);
        return StudentID.NUMERIC;
      }

      return StudentID.values.byName(snapshot.value as String);
    } catch (e) {
      print("Student ID Parse Error: $e");
      return StudentID.NUMERIC;
    }
  }

  static Future<bool> setIDBounds(int? min, int? max) async {
    try {
      final boundsRef = db.child("settings/bounds");

      if (min != null) {
        await boundsRef.child("min").set(min);
      }
      
      if (max != null) {
        await boundsRef.child("max").set(min);
      }

      return true;
    } catch (e) {
      print("Student Id set Bounds Error: $e");
      return false;
    }
  }

  static Future<(int, int)> getIDBounds() async {
    try {
      final boundsRef = db.child("settings/bounds");

      final minEvent = await boundsRef.child("min").once(DatabaseEventType.value);
      final maxEvent = await boundsRef.child("max").once(DatabaseEventType.value);

      if (!minEvent.snapshot.exists) {
        await setIDBounds(8, 8);
        return (8, 8);
      }

      int min = minEvent.snapshot.value as int;
      int max = maxEvent.snapshot.value as int;

      return (min, max);
    } catch (e) {
      print("Student ID Bounds Error: $e");
      return (8, 8);
    }
  }
}