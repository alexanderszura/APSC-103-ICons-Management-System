import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await FirebaseHandler.login();

      if (!success) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Login failed. Please try again.');
        }
        return;
      }

      try {
        await User.loadBans();
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('You don\'t have permission to access this site.');
        }
      }

      await InventoryManager.init();

      InventoryManager.loadUserData(await FirebaseHandler.getUserData());
      InventoryManager.loadJSON(await FirebaseHandler.getSessionData());

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('An error occurred during login: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Login Error',
                style: TextStyle(color: Colors.white),
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
                foregroundColor: Colors.redAccent,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'iCons Inventory System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 80),
            
            // Login button
            OutlinedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 20,
                ),
                backgroundColor: _isLoading ? Colors.grey.withAlpha(75) : null,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
