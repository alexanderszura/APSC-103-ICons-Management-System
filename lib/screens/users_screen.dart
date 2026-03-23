import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_management_system/screens/base_screen.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/data/firebase_handler.dart';

class UsersScreen extends BaseScreen {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => UsersScreenState();
}

class UsersScreenState extends BaseScreenState<UsersScreen> {
  @override
  String? get screenTitle => 'Users';

  static void navigate(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UsersScreen()),
    );
  }

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  List<User> get rawUser => InventoryManager.users.values.toList();
  List<User> get users => _getFilteredUsers();

  List<User> _getFilteredUsers() {
  final q = searchQuery.trim().toLowerCase();

  return rawUser.where((u) {
    final name = u.name.toLowerCase();
    final student = u.studentNumber.toString().toLowerCase();
    final email = u.email.toLowerCase();

    return name.contains(q) ||
        student.contains(q) ||
        email.contains(q);
  }).toList();
}

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _setStrikes(User user, int strikes) async {
    user.withStrikes(strikes);
    if (strikes >= 2) {
      user.banUser(); 
    }else {
      user.unbanUser();
    }

    final success = await FirebaseHandler.setUserStrikes(user.studentNumber, strikes);

    if (!success) {
      if (mounted) {
        showErrorDialog(context, 'Database Error', 'Could not update strikes for ${user.name}');
      }
    } else {
      setState(() {});
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Text('Users', style: TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 36)),
          const SizedBox(height: 20),
          SizedBox(
            width: 600,
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: BaseScreenState.secondaryTextColor,
                  fontSize: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: BaseScreenState.borderColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: BaseScreenState.borderColor, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: users.isEmpty
                ? const Center(child: Text('No users registered', style: TextStyle(color: BaseScreenState.secondaryTextColor)))
                : ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: BaseScreenState.borderColor),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${user.name} #${user.studentNumber}', style: const TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 16)),
                                    Tooltip(
                                      message: "Copy email to clipboard",
                                      mouseCursor: SystemMouseCursors.click, // TODO: Doesn't work
                                      child: SelectableText(
                                        user.email, 
                                        style: const TextStyle(color: BaseScreenState.secondaryTextColor),
                                        onTap: () => Clipboard.setData(ClipboardData(text: user.email)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Builder(
                                      builder: (context) {
                                        final items = InventoryManager.getUserItems(user);
                                        if (items.isEmpty) {
                                          return const Text('No items out', style: TextStyle(color: BaseScreenState.secondaryTextColor));
                                        } else {
                                          return Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: items.map((it) => Chip(
                                              label: Text(it.name, style: const TextStyle(fontSize: 12)),
                                            )).toList(),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text('Strikes: ${user.strikes}', style: const TextStyle(color: BaseScreenState.primaryTextColor)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async => await _setStrikes(user, (user.strikes - 1).clamp(0, 10)),
                                        icon: const Icon(Icons.remove, color: BaseScreenState.primaryTextColor),
                                      ),
                                      IconButton(
                                        onPressed: () async => await _setStrikes(user, (user.strikes + 1).clamp(0, 10)),
                                        icon: const Icon(Icons.add, color: BaseScreenState.primaryTextColor),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(user.isBanned() ? 'BANNED' : 'Active', style: TextStyle(color: user.isBanned() ? Colors.redAccent : BaseScreenState.primaryTextColor)),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
