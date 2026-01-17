import 'package:flutter/material.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class SearchScreen extends BaseScreen {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends BaseScreenState<SearchScreen> {
  @override
  String? get screenTitle => 'Items Released';

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Released Items',
            style: TextStyle(
              color: BaseScreenState.primaryTextColor,
              fontSize: 36,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: 400,
            child: TextField(
              style: const TextStyle(color: BaseScreenState.primaryTextColor),
              decoration: InputDecoration(
                hintText: 'Student Number...',
                hintStyle: const TextStyle(color: BaseScreenState.secondaryTextColor),
                prefixIcon: const Icon(Icons.search, color: BaseScreenState.secondaryTextColor),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BaseScreenState.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: BaseScreenState.borderColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
