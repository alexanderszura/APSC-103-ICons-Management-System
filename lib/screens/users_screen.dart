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

  Future<void> _editUser(User user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final studentNumberController = TextEditingController(text: user.studentNumber);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white24, width: 1),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_outlined, color: Colors.white70, size: 24),
            SizedBox(width: 10),
            Text('Edit User', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _editField(
                label: 'Name',
                controller: nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _editField(
                label: 'Email',
                controller: emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _editField(
                label: 'Student Number',
                controller: studentNumberController,
                icon: Icons.badge_outlined,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
            child: const Text('Save', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );

    nameController.dispose();
    emailController.dispose();
    studentNumberController.dispose();

    if (confirmed != true) return;

    final newName          = nameController.text.trim();
    final newEmail         = emailController.text.trim();
    final newStudentNumber = studentNumberController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty || newStudentNumber.isEmpty) {
      if (mounted) showErrorDialog(context, 'Validation Error', 'All fields are required.');
      return;
    }

    // If the student number is changing, make sure it isn't already taken
    if (newStudentNumber != user.studentNumber &&
        InventoryManager.users.containsKey(newStudentNumber)) {
      if (mounted) showErrorDialog(context, 'Validation Error', 'Student number $newStudentNumber is already registered.');
      return;
    }

    final oldStudentNumber = user.studentNumber;

    final success = await FirebaseHandler.updateUser(
      oldStudentNumber: oldStudentNumber,
      newStudentNumber: newStudentNumber,
      newName: newName,
      newEmail: newEmail,
      strikes: user.strikes,
    );

    if (!success) {
      if (mounted) showErrorDialog(context, 'Database Error', 'Could not update ${user.name}.');
      return;
    }

    // Update in-memory state
    if (newStudentNumber != oldStudentNumber) {
      InventoryManager.users.remove(oldStudentNumber);
      final items = InventoryManager.inventory.remove(user);
      user.studentNumber = newStudentNumber;
      InventoryManager.users[newStudentNumber] = user;
      if (items != null) InventoryManager.inventory[user] = items;
    }

    user.name  = newName;
    user.email = newEmail;

    setState(() {});
  }

  Widget _editField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        isDense: true,
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 12),
            Text('Delete User', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${user.name} (#${user.studentNumber})?\n\nThis cannot be undone.',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await FirebaseHandler.deleteUser(user.studentNumber);

    if (!success) {
      if (mounted) showErrorDialog(context, 'Database Error', 'Could not delete ${user.name}.');
      return;
    }

    InventoryManager.users.remove(user.studentNumber);
    InventoryManager.inventory.remove(user);
    setState(() {});
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
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () async => await _editUser(user),
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
                                        tooltip: 'Edit user',
                                      ),
                                      IconButton(
                                        onPressed: () async => await _deleteUser(user),
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                        tooltip: 'Delete user',
                                      ),
                                    ],
                                  ),
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
