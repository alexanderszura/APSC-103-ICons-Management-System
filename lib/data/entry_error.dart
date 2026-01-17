import 'package:icons_management_system/data/invetory_manager.dart';
import 'package:icons_management_system/data/user.dart';

class EntryError {
  String error;

  EntryError(this.error);

  String getError() => error;

  static EntryError userBanned(User user) => EntryError("${user.name} Is Banned");
  static EntryError itemOut(User user) => EntryError("This User has ${InvetoryManager.getUserItem(user)?.name} currently out");

  @override
  String toString() {
    return error;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntryError && other.error == error;
  }

  @override
  int get hashCode => error.hashCode;
}