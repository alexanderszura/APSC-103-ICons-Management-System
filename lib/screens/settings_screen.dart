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

  TextEditingController minLengthController = TextEditingController(
    text: InventoryManager.minLength.toString()
  );

  TextEditingController maxLengthController = TextEditingController(
    text: InventoryManager.maxLength.toString()
  );

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  void dispose() {
    minLengthController.dispose();
    maxLengthController.dispose();

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
            )
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