import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class Item {
  String name;
  File image;
  DateTime? time;
  
  Item({required File imagePath}) : image = imagePath, name = withoutExtension(basename(imagePath.path));

  String getName() => name;
  Widget buildImage() => Image.file(image);

  Item copy() => Item(imagePath: image);

  Item withTimeStamp({DateTime? time}) {
    time ??= DateTime.now();
    this.time = time;

    return this;
  }

  DateTime? getTime() => time;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Item && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}