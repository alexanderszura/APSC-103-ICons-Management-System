import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:path_provider/path_provider.dart';

abstract class FileHandler {

  static List<File> itemFiles = [];

  static Future<void> init() async {
    itemFiles = await _loadImageFiles();
    await User.loadBans();
  }

  static Future<String> getDirectory() async {
    final folderName = "ICons";

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    return "$path/$folderName";
  }

  static Future<File> _loadBanFile() async {
    final fileName = "banned_users.txt";

    final dir = await getDirectory();

    return File("$dir/$fileName").create(recursive: true);
  }

  static Future<List<String>> getBannedIDs() async {
    File banFile = await _loadBanFile();

    return await banFile.readAsLines();
  }

  static Future<List<File>> _loadImageFiles() async {
    final path = await getDirectory();

    var dir = await Directory("$path/Items").create(recursive: true);

    List<File> files = [];
    await for (var file in dir.list(followLinks: false)) {
      files.add(File(file.path));
    }

    return files;
  }

  static List<Item> loadItems() {
    List<Item> items = [];

    for (File file in itemFiles) {
      items.add(Item(imagePath: file));
    }

    return items;
  }

  static Future<File> _loadSessionFile() async {
    final fileName = "session.icn";

    final dir = await getDirectory();

    return File('$dir/$fileName');
  }

  static Future<Map<String, dynamic>> getFileContents() async {
    final file = await _loadSessionFile();

    bool exists = await file.exists();

    if (!exists) {
      return {};
    }

    try {
      return json.decode(await file.readAsString());
    } catch (e) {
      return {};
    }
  }

  static Future<bool> writeFile(Map<String, dynamic> data) async {
    final file = await _loadSessionFile();

    final jsonData = json.encode(data);

    try {
      if (!await file.exists()) {
        await file.create(recursive: true);
      }
      
      await file.writeAsString(jsonData);

      return true;
    } catch (e) {
      print("Couldn't write to file ${file.path}");
    }
    
    return false;
  }
}