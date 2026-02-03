import 'package:flutter/material.dart';
import 'package:icons_management_system/data/item.dart';

class InventoryItem {
  String name;
  String url;
  int quantity;
  
  InventoryItem(this.name, this.url, this.quantity);

  String getName() => name;
  Widget buildImage(double width, double height) => Image.network(url, fit: BoxFit.contain);

  InventoryItem copy() => InventoryItem(name, url, quantity);

  Item userItem() => Item(name);

  static InventoryItem? fromJSON(Map<String, dynamic> data) {
    try {
      return InventoryItem(
        data['item'],
        data['url'],
        data['quantity']
      );
    } catch (e) {
      print("Unable to parse data...");
      print(data);
      print(e);

      return null;
    }
  }

  Map<String, dynamic> toJSON() {
    return {
      "item": name,
      "url" : url,
      "quantity": quantity
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryItem && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}