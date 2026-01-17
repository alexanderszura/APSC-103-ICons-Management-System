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

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    super.dispose();
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
                            final name = nameController.text.trim();
                            final studentNumber = studentIdController.text.trim();

                            if (name.isEmpty || studentNumber.isEmpty) {
                              return;
                            }

                            final user = User.create(name, studentNumber);

                            Item item = FileHandler.loadItems()[0];

                            final EntryError? result = InvetoryManager.addEntry(user, item);

                            if (result == null) {
                              await updateSessionFile();
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
