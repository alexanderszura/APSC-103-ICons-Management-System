import 'package:flutter/material.dart';
import 'package:icons_management_system/data/entry_error.dart';
import 'package:icons_management_system/data/file_handler.dart';
import 'package:icons_management_system/data/invetory_manager.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class TakeoutScreen extends BaseScreen {
  const TakeoutScreen({super.key});

  @override
  State<TakeoutScreen> createState() => TakeoutScreenState();
}

class TakeoutScreenState extends BaseScreenState<TakeoutScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();

  final itemOptions = FileHandler.loadItems();

  final double imageWidth = 400;
  final double imageHeight = 400;

  Item? selectedItem;

  @override
  String? get screenTitle => 'Take-out';

  Future<void> updateSessionFile() async {
    if (!await FileHandler.writeFile(InvetoryManager.toJSON())) {
      print("Unable to save session data...");
    }
  }

  (User?, EntryError?) submitPressed() {
    final name = nameController.text.trim();
    final studentNumber = studentIdController.text.trim();

    if (name.isEmpty || studentNumber.isEmpty) {
      showErrorDialog(
        context,
        'Missing Information',
        'Please enter both name and student ID.',
      );
      return (null, null);
    }

    if (selectedItem == null) {
      showErrorDialog(
        context,
        'No Item Selected',
        'Please select an item from the dropdown.',
      );
      return (null, null);
    }

    final user = User.create(name, studentNumber);

    return (user, InvetoryManager.addEntry(user, selectedItem!));
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TakeoutScreen()),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left side - Form
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ICon Database',
                style: TextStyle(
                  color: BaseScreenState.primaryTextColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: nameController,
                  style: const TextStyle(color: BaseScreenState.primaryTextColor),
                  decoration: const InputDecoration(
                    hintText: 'Full Name...',
                    hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: BaseScreenState.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: BaseScreenState.borderColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: studentIdController,
                  style: const TextStyle(color: BaseScreenState.primaryTextColor),
                  decoration: const InputDecoration(
                    hintText: 'Student ID...',
                    hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: BaseScreenState.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: BaseScreenState.borderColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 260,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: BaseScreenState.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BaseScreenState.secondaryTextColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
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
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () async {
                  var (user, result) = submitPressed();

                  if (user == null) {
                    return;
                  }

                  if (result == null) {
                    showSuccessDialog(
                      context,
                      'Success!',
                      'Entry added successfully for ${user.name}.',
                    );

                    nameController.clear();
                    studentIdController.clear();

                    await updateSessionFile();

                    setState(() {
                      selectedItem = null;
                    });
                  } else {
                    showErrorDialog(
                      context,
                      'Error',
                      result.message,
                      showAllowButton: true,
                      onAllow: () async {
                        InvetoryManager.addEntry(user, selectedItem!, force: true);

                        showSuccessDialog(
                          context,
                          'Success!',
                          'Entry added successfully for ${user.name} (forced).',
                        );

                        await updateSessionFile();

                        nameController.clear();
                        studentIdController.clear();
                        setState(() {
                          selectedItem = null;
                        });
                      },
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BaseScreenState.borderColor),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(width: 80),
          Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: selectedItem == null
                  ? const SizedBox()
                  : selectedItem!.buildImage(imageWidth, imageHeight),
            ),
          ),
        ],
      ),
    );
  }
}
