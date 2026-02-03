import 'package:flutter/material.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/user.dart';
import 'package:icons_management_system/data/item.dart';
import 'package:icons_management_system/data/firebase_handler.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class SearchScreen extends BaseScreen {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends BaseScreenState<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  String? get screenTitle => 'Items Released';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SearchScreen()),
    );
  }

  List<MapEntry<User, List<Item>>> _getFilteredItems() {
    final entries = InventoryManager.inventory.entries.toList();
    
    if (searchQuery.isEmpty) {
      return entries;
    }
    
    return entries.where((entry) {
      final user = entry.key;
      final items = entry.value;
      
      // Search by name, student ID, or item names
      final nameMatch = user.name.toLowerCase().contains(searchQuery.toLowerCase());
      final idMatch = user.studentNumber.toLowerCase().contains(searchQuery.toLowerCase());
      final itemMatch = items.any((item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()));
      
      return nameMatch || idMatch || itemMatch;
    }).toList();
  }

  void _removeItem(User user, Item item) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.orangeAccent, width: 2),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orangeAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Confirm Return',
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Text(
            'Mark ${item.name} as returned for ${user.name}?',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white54,
              ),
              child: const Text('CANCEL', style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.greenAccent,
              ),
              child: const Text('CONFIRM', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        InventoryManager.removeItemFromUser(user, item);
        
        if (InventoryManager.inventory[user]?.isEmpty ?? false) {
          InventoryManager.removeUserItemData(user);
        }
      });
      
      await updateSessionFile();
    }
  }

  Future<void> updateSessionFile() async {
    if (!await FirebaseHandler.sync(InventoryManager.toJSON())) {
      print("Unable to save session data...");
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    final filteredItems = _getFilteredItems();
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const Text(
            'Released items',
            style: TextStyle(
              color: BaseScreenState.primaryTextColor,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 40),
          
          SizedBox(
            width: 600,
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: BaseScreenState.secondaryTextColor,
                  fontSize: 18,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: BaseScreenState.borderColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: BaseScreenState.borderColor, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 40),
          
          // List of released items
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items currently released',
                      style: TextStyle(
                        color: BaseScreenState.secondaryTextColor,
                        fontSize: 18,
                      ),
                    ),
                  )
                : SizedBox(
                    width: 600,
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final entry = filteredItems[index];
                        final user = entry.key;
                        final items = entry.value;
                        
                        return Column(
                          children: [
                            ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: BaseScreenState.borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${user.name} #${user.studentNumber}',
                                        style: const TextStyle(
                                          color: BaseScreenState.primaryTextColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: BaseScreenState.primaryTextColor,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => _removeItem(user, item),
                                      child: const Text(
                                        'X',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        );
                      },
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
