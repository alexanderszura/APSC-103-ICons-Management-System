import 'package:icons_management_system/data/invetory_manager.dart';
import 'package:icons_management_system/data/user.dart';

class EntryError {
  String error;

  EntryError(this.error);

  String getError() => error;

  static EntryError userBanned(User user) => EntryError("${user.name} Is Banned");
  static EntryError itemOut(User user) => EntryError("This User has ${InvetoryManager.getUserItem(user)?.name} currently out");
}