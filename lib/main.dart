import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/invetory_manager.dart';
import 'package:icons_management_system/screens/takeout_screen.dart';
import 'package:icons_management_system/screens/search_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseHandler.init();

  InvetoryManager.loadUserData(await FirebaseHandler.getUserData());
  InvetoryManager.loadJSON(await FirebaseHandler.getSessionData());

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
          seedColor: Colors.blueAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ICon Database',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 80),
            
            // Take-out Button
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TakeoutScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'Take-out',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Search Button
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
              ),
              child: const Text(
                'Search',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
