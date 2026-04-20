import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_database/firebase_database.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:flutter/foundation.dart' as foundation;

abstract class FirebaseHandler {

  FirebaseHandler._();

  static final instance = FirebaseDatabase.instance;

  static final db = instance.ref(
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

  // Converts an email address to a Firebase-safe key.
  // Replaces '.' with ',' and '@' with '|' so it can be used as a DB key.
  static String emailToKey(String email) {
    return email.trim().toLowerCase().replaceAll('.', ',').replaceAll('@', '|');
  }

  static Future<bool> addAllowedEmail(String email) async {
    try {
      final key = emailToKey(email);
      final ref = instance.ref('allowed_emails').child(key);
      await ref.set(true);
      return true;
    } catch (e) {
      print('Add Allowed Email Error: $e');
      return false;
    }
  }

  static Future<bool> removeAllowedEmail(String email) async {
    try {
      final key = emailToKey(email);
      final ref = instance.ref('allowed_emails').child(key);
      await ref.remove();
      return true;
    } catch (e) {
      print('Remove Allowed Email Error: $e');
      return false;
    }
  }

  static Future<List<String>> getAllowedEmailKeys() async {
    try {
      final ref = instance.ref('allowed_emails');
      final event = await ref.once(DatabaseEventType.value);
      if (event.snapshot.value == null) return [];
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      return map.keys.toList();
    } catch (e) {
      print('Get Allowed Emails Error: $e');
      return [];
    }
  }

  static Future<bool> isCurrentUserEmailAllowed() async {
    final currentEmail = FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null) return false;
    final key = emailToKey(currentEmail);
    final allowedKeys = await getAllowedEmailKeys();
    return allowedKeys.contains(key);
  }

  static Future<bool> addUidRemoveEmail(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) return false;

      final emailKey = emailToKey(user.email!);

      final allowedRef = instance.ref('allowed_emails').child(emailKey);

      final snapshot = await allowedRef.get();
      if (!snapshot.exists) {
        print('Email not allowed');
        return false;
      }

      await instance.ref().update({
        'staff/$uid': true,
        'allowed_emails/$emailKey': null,
      });


      return true;
    } catch (e) {
      print('Error Adding UID + Removing Email: $e');
      return false;
    }
  }

  static Future<bool> updateUser({
    required String oldStudentNumber,
    required String newStudentNumber,
    required String newName,
    required String newEmail,
    required int strikes,
  }) async {
    try {
      final bool numberChanged = oldStudentNumber != newStudentNumber;

      final Map<String, dynamic> userData = {
        'name': newName,
        'student_id': newStudentNumber,
        'email': newEmail,
        'strikes': strikes,
      };

      if (numberChanged) {
        // Write under new key
        await db.child('users').child(newStudentNumber).set(userData);
        // Delete old key
        await db.child('users').child(oldStudentNumber).remove();

        final bannedSnap = await db.child('banned_ids').child(oldStudentNumber).once(DatabaseEventType.value);
        if (bannedSnap.snapshot.exists) {
          await db.child('banned_ids').child(newStudentNumber).set(true);
          await db.child('banned_ids').child(oldStudentNumber).remove();
        }

        final itemsSnap = await db.child('items_out').child(oldStudentNumber).once(DatabaseEventType.value);
        if (itemsSnap.snapshot.exists) {
          await db.child('items_out').child(newStudentNumber).set(itemsSnap.snapshot.value);
          await db.child('items_out').child(oldStudentNumber).remove();
        }
      } else {
        await db.child('users').child(oldStudentNumber).update(userData);
      }

      return true;
    } catch (e) {
      print('Update User Error: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String studentNumber) async {
    try {
      await db.child('users').child(studentNumber).remove();
      await db.child('banned_ids').child(studentNumber).remove();
      return true;
    } catch (e) {
      print('Delete User Error: $e');
      return false;
    }
  }

  static Future<bool> yearReset() async {
    try {
      await db.child('users').remove();
      await db.child('banned_ids').remove();
      await db.child('items_out').remove();
      return true;
    } catch (e) {
      print('Year Reset Error: $e');
      return false;
    }
  }
}