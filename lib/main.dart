import 'package:flutter/material.dart';
import 'package:icons_management_system/data/entry_error.dart';
import 'package:icons_management_system/data/file_handler.dart';
import 'package:icons_management_system/data/invetory_manager.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FileHandler.init();

  InvetoryManager.loadJSON(await FileHandler.getFileContents());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICon Tracker System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();

  final itemOptions = FileHandler.loadItems();

  final double imageWidth = 400;
  final double imageHeight = 400;

  Item? selectedItem;

  Future<void> updateSessionFile() async {
    if (!await FileHandler.writeFile(InvetoryManager.toJSON())) {
      print("Unable to save session data...");
    }
  }

  (User?, EntryError?) submitPressed() {
    final name = nameController.text.trim();
    final studentNumber = studentIdController.text.trim();

    if (name.isEmpty || studentNumber.isEmpty) {
      _showErrorDialog(
        context,
        'Missing Information',
        'Please enter both name and student ID.',
      );
      return (null, null);
    }

    if (selectedItem == null) {
      _showErrorDialog(
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

  void _showErrorDialog(BuildContext context, String title, String message, {User? user, bool allowForce = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            if (allowForce && user != null && selectedItem != null)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  InvetoryManager.addEntry(user, selectedItem!, force: true);
                  
                  _showSuccessDialog(
                    context,
                    'Success!',
                    'Entry added successfully for ${user.name} (forced).',
                  );

                  await updateSessionFile();
                  
                  // Clear the form
                  nameController.clear();
                  studentIdController.clear();
                  setState(() {
                    selectedItem = null;
                  });
                }, 
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                ),
                child: const Text('ALLOW', style: TextStyle(fontSize: 16))
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.greenAccent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.greenAccent,
              ),
              child: const Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),

      drawer: Drawer(
        backgroundColor: const Color(0xFF2A2A2A),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white),
              title: const Text('Settings',
                  style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
            children: [
              Positioned(
                top: 16,
                left: 16,
                child: OutlinedButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ),

              Center(
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
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Full Name...',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: 260,
                      child: TextField(
                        controller: studentIdController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Student ID...',
                          hintStyle: TextStyle(color: Colors.white54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Container(
                      width: 260,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white54),
                        boxShadow: [
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
                          hint: Text(
                            'Select Item',
                            style: TextStyle(color: Colors.white54),
                          ),
                          dropdownColor: Color(0xFF2A2A2A),
                          iconEnabledColor: Colors.white,
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
                                style: TextStyle(color: Colors.white),
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
                              _showSuccessDialog(
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
                              _showErrorDialog(
                                context,
                                'Error',
                                result.message,
                                user: user,
                                allowForce: true,
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 14,
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16),
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
                        child: selectedItem == null ? SizedBox() : selectedItem!.buildImage(imageWidth, imageHeight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
