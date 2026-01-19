import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';

class Item {
  String name;
  String url;
  DateTime? time;
  
  Item(this.name, this.url);

  String getName() => name;
  Widget buildImage(double width, double height) => Image.network(url, fit: BoxFit.contain);

  Item withTimestamp({DateTime? time}) {
    time ??= DateTime.now();
    this.time = time;

    return this;
  }

  Item copy() => Item(name, url);

  DateTime? getTimestamp() => time;

  static Item? fromName(String name) {
    for (Item item in FirebaseHandler.loadItems()) {
      if (item.name == name) {
        return item;
      }
    }
    
    return null;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}