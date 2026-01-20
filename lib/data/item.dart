import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/tools/date_from.dart';

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

  static Item? fromJSON(Map<String, dynamic> data) {
    try {
      return Item(
        data['item'],
        data['url']
      );
    } catch (e) {
      print("Unable to parse data...");
      print(data);
      print(e);

      return null;
    }
  }

  Map<String, dynamic> toJSON(bool isPlayer) {
    if (isPlayer) {
      return {
        "item": name,
        "time": TimeHelper.shorten(time ?? DateTime.now())
      };
    }

    return {
      "item": name,
      "url" : url,
    };
  }

  static Item? fromName(String name) {
    for (Item item in FirebaseHandler.getItems()) {
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