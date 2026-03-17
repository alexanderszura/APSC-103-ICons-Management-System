import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/screens/home_screen.dart';
import 'package:icons_management_system/screens/login_screen.dart';
import 'data/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (FirebaseHandler.isLoggedIn()) {
    await InventoryManager.init();

    InventoryManager.loadUserData(await FirebaseHandler.getUserData());
    InventoryManager.loadJSON(await FirebaseHandler.getSessionData());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {  
    Widget home = FirebaseHandler.isLoggedIn() ? HomeScreen() : LoginScreen();

    return MaterialApp(
      title: 'iCons Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
      ),
      home: home,
    );
  }
}
