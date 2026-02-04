import 'package:flutter/material.dart';
import 'package:icons_management_system/screens/base_screen.dart';
import 'package:icons_management_system/screens/takeout_screen.dart';
import 'package:icons_management_system/screens/search_screen.dart';

class HomeScreen extends BaseScreen {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();

  static void navigate(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}

class HomeScreenState extends BaseScreenState<HomeScreen> {
  @override
  String? get screenTitle => 'Home';

  static void navigate(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'iCons Database',
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
    );
  }
}
