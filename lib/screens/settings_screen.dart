import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class SettingsScreen extends BaseScreen {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends BaseScreenState<SettingsScreen> {

  final TextEditingController minLengthController = TextEditingController(
    text: InventoryManager.minLength.toString()
  );

  final TextEditingController maxLengthController = TextEditingController(
    text: InventoryManager.maxLength.toString()
  );

  final TextEditingController _emailController = TextEditingController();
  List<String> _allowedEmailKeys = [];
  bool _emailsLoading = true;

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAllowedEmails();
  }

  Future<void> _loadAllowedEmails() async {
    final keys = await FirebaseHandler.getAllowedEmailKeys();
    setState(() {
      _allowedEmailKeys = keys;
      _emailsLoading = false;
    });
  }

  @override
  void dispose() {
    minLengthController.dispose();
    maxLengthController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: const Center(
          child: Text(
            "Settings",
            style: TextStyle(color: Colors.white),
          )
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Student ID"),
            _settingsCard(
              children: [
                _dropdownTile(
                  title: "Student ID Type",
                  value: InventoryManager.studentIDType,
                  items: StudentID.values,
                  onChanged: (value) async {
                    if (value == null) return;

                    InventoryManager.studentIDType = value;

                    await FirebaseHandler.setStudentIdType(value);

                    setState(() {});
                  }
                ),
                _textTile(
                  title: "Student ID Min Length",
                  controller: minLengthController,
                  onChange: (text) async {
                    int? value = int.tryParse(text);

                    if (value == null) {
                      return;
                    }
                    
                    InventoryManager.minLength = value;

                    await FirebaseHandler.setIDBounds(value, null);
                  }
                ),
                _textTile(
                  title: "Student ID Max Length",
                  controller: maxLengthController,
                  onChange: (text) async {
                    int? value = int.tryParse(text);

                    if (value == null) {
                      return;
                    }
                    
                    InventoryManager.maxLength = value;

                    await FirebaseHandler.setIDBounds(null, value);
                  }
                )
              ]
            ),

            const SizedBox(height: 28),

            _sectionTitle("Website Access"),
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Grant access by email",
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'user@example.com',
                              hintStyle: TextStyle(color: Colors.white38),
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () async {
                            final email = _emailController.text.trim();
                            if (email.isEmpty || !email.contains('@')) return;

                            final success = await FirebaseHandler.addAllowedEmail(email);

                            if (success) {
                              _emailController.clear();
                              await _loadAllowedEmails();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Access granted to $email'),
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                );
                              }
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Allowed accounts:",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    if (_emailsLoading)
                      const Center(child: CircularProgressIndicator(color: Colors.white38))
                    else if (_allowedEmailKeys.isEmpty)
                      const Text(
                        'No emails added yet.',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      )
                    else
                      ..._allowedEmailKeys.map((key) {
                        // Convert key back to readable email for display
                        final displayEmail = key.replaceAll(',', '.').replaceAll('|', '@');
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  displayEmail,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                                tooltip: 'Remove access',
                                onPressed: () async {
                                  await FirebaseHandler.removeAllowedEmail(displayEmail);
                                  await _loadAllowedEmails();
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            _sectionTitle("Danger Zone"),
            SizedBox(
              width: double.infinity,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withAlpha(120)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.refresh, color: Colors.redAccent, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year-End Reset',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Deletes all user accounts and items out. Inventory and settings are kept.',
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () async {
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
                                Text('Year-End Reset', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            content: const Text(
                              'This will permanently delete:\n\n• All registered user accounts\n• All items currently checked out\n\nInventory items and settings will be kept.\n\nThis cannot be undone. Are you sure?',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                child: const Text('Reset', style: TextStyle(fontSize: 15)),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true) return;

                        final success = await FirebaseHandler.yearReset();

                        if (!context.mounted) return;

                        if (!success) {
                          showErrorDialog(context, 'Reset Failed', 'Could not complete the year-end reset. Please try again.');
                        } else {
                          InventoryManager.users.clear();
                          InventoryManager.inventory.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Year-end reset complete.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                      child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _settingsCard({required List<Widget> children}) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children
            .map((child) => Expanded(child: child))
            .toList(),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _textTile({
    required String title,
    required TextEditingController controller,
    required Function(String) onChange,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChange,
      ),
    );
  }


  // ignore: unused_element
  Widget _toggleTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
    );
  }

  // ignore: unused_element
  Widget _dropdownTile<T>({
    required String title,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            initialValue: value,
            dropdownColor: const Color(0xFF2A2A2A),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
            iconEnabledColor: Colors.white,
            onChanged: onChanged,
            items: items.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buttonTile(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            alignment: AlignmentGeometry.center,
            side: const BorderSide(color: BaseScreenState.borderColor),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(
              horizontal: 48,
              vertical: 14,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 16),
          ),
        )
      )
    );
  }

  // ignore: unused_element
  Widget _divider() {
    return const Divider(
      color: Colors.white24,
      height: 1,
      thickness: 1,
    );
  }
}