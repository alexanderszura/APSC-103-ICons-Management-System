import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class SettingsScreen extends BaseScreen {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends BaseScreenState<SettingsScreen> {

  final TextEditingController itemController = TextEditingController();
  final TextEditingController urlController  = TextEditingController();

  List<Item> itemOptions = FirebaseHandler.getItems();

  Item? selectedItem;

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  void dispose() {
    itemController.dispose();
    urlController.dispose();

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
          children: [
            _sectionTitle("Items"),
            _settingsCard(
              children: [
                _buttonTile(
                  "Add Item",
                  () => _addItemDialog(context)
                ),
                _buttonTile(
                  "Removes Item",
                  () => _removeItemDialog(context),
                ),
              ]
            )
          ],
        ),
      ),
    );
  }

  void _addItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.greenAccent, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Add Item",
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add an Item to the Database",
                style: TextStyle(color: BaseScreenState.primaryTextColor)
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Item Name...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: itemController,
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Image URL...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: urlController,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                String name = itemController.text;
                String url  = urlController .text;

                itemController.clear();
                urlController .clear();

                if (await FirebaseHandler.addItem(name, url)) {
                  if (context.mounted) {
                    showSuccessDialog(
                      context,
                      "Success!",
                      "Successfully added $name to the Database"
                    );
                  }
                } else {
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      "Database Error",
                      "Error Adding $name with url $url to the database"
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.greenAccent,
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _removeItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Remove Item",
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Remove an Item from the Database",
                style: TextStyle(color: BaseScreenState.primaryTextColor)
              ),
              const SizedBox(height: 24),
              DropdownButtonHideUnderline(
                  child: DropdownButton<Item>(
                    value: selectedItem,
                    hint: const Text(
                      'Select Item',
                      style: TextStyle(color: BaseScreenState.secondaryTextColor),
                    ),
                    dropdownColor: BaseScreenState.surfaceColor,
                    iconEnabledColor: BaseScreenState.primaryTextColor,
                    isExpanded: true,
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                    items: itemOptions.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item.name,
                          style: const TextStyle(color: BaseScreenState.primaryTextColor),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                if (selectedItem == null) {
                  showErrorDialog(
                    context, 
                    "Error",
                    "No Item Selected"
                  );

                  return;
                }

                if (await FirebaseHandler.removeItem(selectedItem!)) {
                  if (context.mounted) {
                    showSuccessDialog(
                      context,
                      "Success!",
                      "Successfully removed ${selectedItem!.name} from the Database"
                    );
                  }
                } else {
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      "Database Error",
                      "Error removing ${selectedItem!.name} from the database"
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('Remove', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

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
        children: children,
      ),
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
  Widget _dropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF2A2A2A),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
            ),
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