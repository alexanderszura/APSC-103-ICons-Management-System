import 'package:flutter/material.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/tools/entry_error.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class TakeoutScreen extends BaseScreen {
  const TakeoutScreen({super.key});

  @override
  State<TakeoutScreen> createState() => TakeoutScreenState();
}

class TakeoutScreenState extends BaseScreenState<TakeoutScreen> {
  final TextEditingController nameController      = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController emailController     = TextEditingController();

  List<InventoryItem> itemOptions = InventoryManager.getInventory();

  final double imageWidth = 400;
  final double imageHeight = 400;

  InventoryItem? selectedItem;

  @override
  String? get screenTitle => 'Take-out';

  Future<void> updateSessionFile() async {
    if (!await FirebaseHandler.sync(InventoryManager.toJSON())) {
      print("Unable to save session data...");
    }
  }

  (User?, EntryError?) submitPressed() {
    final studentNumber = studentIdController.text.trim();

    if (studentNumber.isEmpty) {
      showErrorDialog(
        context,
        'Missing Information',
        'Please enter student ID.',
      );
      return (null, EntryError.missingInfo());
    }

    if (!InventoryManager.isRegistered(studentNumber)) {
      _showRegisterDialog(context, studentNumber);
      return (null, EntryError.notRegistered());
    }

    if (selectedItem == null) {
      showErrorDialog(
        context,
        'No Item Selected',
        'Please select an item from the dropdown.',
      );
      return (null, EntryError.missingInfo());
    }

    nameController.clear();
    emailController.clear();
    studentIdController.clear();

    final user = InventoryManager.getUser(studentNumber);

    return (user, InventoryManager.addEntry(user!, selectedItem!));
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

  void _showRegisterDialog(BuildContext context, String studentNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orangeAccent, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orangeAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Register User",
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add a User to the Database",
                style: TextStyle(color: BaseScreenState.primaryTextColor)
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'User Name...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: nameController,
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'User Email...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: emailController,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                String name  = nameController .text;
                String email = emailController.text;

                User user = InventoryManager.createUser(name, studentNumber, email);

                if (await FirebaseHandler.registerUser(user)) {
                  submitPressed();

                  if (context.mounted) {
                    showSuccessDialog(
                      context,
                      "Success!",
                      "Successfully added $name to the Database"
                    );
                  }

                  setState(() {
                    selectedItem = null;
                  });
                } else {
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      "Database Error",
                      "Error Adding $name to the Database"
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.greenAccent,
              ),
              child: const Text('Register', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
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
                'iCons Database',
                style: TextStyle(
                  color: BaseScreenState.primaryTextColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
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
                  child: DropdownButton<InventoryItem>(
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
                    if (result != EntryError.notRegistered()) {
                      showErrorDialog(
                        context,
                        'Error',
                        'Unable to sync data',
                      );
                    }
                    
                    return;
                  }

                  if (result == null) {
                    showSuccessDialog(
                      context,
                      'Success!',
                      'Entry added successfully for ${user.name}.',
                    );
                  } else {
                    showErrorDialog(
                      context,
                      'Error',
                      result.message,
                      showAllowButton: true,
                      onAllow: () async {
                        InventoryManager.addEntry(user, selectedItem!, force: true);

                        showSuccessDialog(
                          context,
                          'Success!',
                          'Entry added successfully for ${user.name} (forced).',
                        );
                      },
                    );
                  }

                  await updateSessionFile();

                  setState(() {
                    selectedItem = null;
                  });
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
