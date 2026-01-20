import 'package:icons_management_system/data/invetory_manager.dart';
import 'package:icons_management_system/data/user.dart';

class EntryError {
  String message;

  EntryError(this.message);

  String getMessage() => message;

  static EntryError userBanned(User user) => EntryError("${user.name} Is Banned");
  static EntryError itemOut(User user) {
    var itemNames = InvetoryManager.getUserItems(user);
    
    var message = itemNames.isEmpty
        ? "This user has nothing currently out"
        : "This User has ${itemNames.map((i) => i.name).join(', ')} currently out";
        
    return EntryError(message);
  }
  static EntryError missingInfo() => EntryError("Missing info inputted");
  static EntryError notRegistered() => EntryError("This user is not registered!");

  @override
  String toString() => getMessage();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntryError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}