import 'package:flutter/material.dart';
import 'package:icons_management_system/screens/search_screen.dart';
import 'package:icons_management_system/screens/takeout_screen.dart';

abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2A2A2A);
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Colors.white54;
  static const Color borderColor = Colors.white;

  Widget buildContent(BuildContext context);

  String? get screenTitle => null;

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Text(
            'Menu',
            style: TextStyle(color: primaryTextColor, fontSize: 24),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.home, color: primaryTextColor),
            title: const Text('Home', style: TextStyle(color: primaryTextColor)),
            onTap: () => _navigateToHome(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: primaryTextColor),
            title: const Text('Take-out', style: TextStyle(color: primaryTextColor)),
            onTap: () => TakeoutScreenState.navigate(context),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: primaryTextColor),
            title: const Text('Released Items', style: TextStyle(color: primaryTextColor)),
            onTap: () => SearchScreenState.navigate(context),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.settings, color: primaryTextColor),
            title: const Text('Settings', style: TextStyle(color: primaryTextColor)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget _buildMenuButton(BuildContext context) {
    return Positioned(
      top: 16,
      left: 16,
      child: OutlinedButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: borderColor),
          padding: const EdgeInsets.all(12),
        ),
        child: const Icon(Icons.menu, color: primaryTextColor),
      ),
    );
  }

  void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onAllow,
    bool showAllowButton = false,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
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
                style: const TextStyle(color: primaryTextColor),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            if (showAllowButton && onAllow != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAllow();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                ),
                child: const Text('ALLOW', style: TextStyle(fontSize: 16)),
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

  void showSuccessDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.greenAccent, width: 2),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(color: primaryTextColor),
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
      backgroundColor: backgroundColor,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
            children: [
              buildContent(context),
              _buildMenuButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
