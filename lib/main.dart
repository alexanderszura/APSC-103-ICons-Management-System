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
                child: Column(
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
                    const SizedBox(height: 40),

                    OutlinedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final studentNumber = studentIdController.text.trim();

                        if (name.isEmpty || studentNumber.isEmpty) {
                          return;
                        }

                        final user = await User.create(name, studentNumber);

                        Item item = (await FileHandler.loadItems())[0];

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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
