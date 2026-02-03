import 'package:flutter/material.dart';
import 'package:icons_management_system/data/inventory_item.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/screens/base_screen.dart';

class InventoryScreen extends BaseScreen {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends BaseScreenState<InventoryScreen> {
  final TextEditingController searchController   = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final TextEditingController itemController = TextEditingController();
  final TextEditingController urlController  = TextEditingController();

  String searchQuery = '';

  List<InventoryItem> get itemOptions => InventoryManager.getInventory();
  InventoryItem? selectedItem;

  @override
  String? get screenTitle => 'Inventory Screen';

  @override
  void dispose() {
    searchController  .dispose();
    quantityController.dispose();

    itemController.dispose();
    urlController .dispose();

    super.dispose();
  }

  static void navigate(BuildContext context) {
    Navigator.pop(context); // Close drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const InventoryScreen()),
    );
  }

  List<InventoryItem> _getFilteredItems() {
    final items = InventoryManager.items;
    
    if (searchQuery.isEmpty) {
      return items;
    }
    
    return items.where((item) => item.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  void _showEditDialog(InventoryItem item, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orangeAccent, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orangeAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Edit Inventory",
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Edit ${item.name} Quantity",
                style: TextStyle(color: BaseScreenState.primaryTextColor)
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Quantity...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: quantityController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                int? quantity = int.tryParse(quantityController.text);

                if (quantity == null) {
                  showErrorDialog(
                    context,
                    "Illegal Input Error",
                    "Could not determain the number value of quantity"
                  );

                  return;
                }

                await InventoryManager.updateQuantity(item, quantity);

                setState(() {});
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.greenAccent,
              ),
              child: const Text('Register', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _addItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.greenAccent, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.greenAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Add Item",
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add an Item to the Database",
                style: TextStyle(color: BaseScreenState.primaryTextColor)
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Item Name...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: itemController,
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Image URL...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: urlController,
              ),
              const SizedBox(height: 24),
              TextField(
                style: const TextStyle(color: BaseScreenState.primaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Item Quantity...',
                  hintStyle: TextStyle(color: BaseScreenState.secondaryTextColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: BaseScreenState.borderColor),
                  ),
                ),
                controller: quantityController,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                String name = itemController.text;
                String url  = urlController .text;
                
                int? quantity = int.tryParse(quantityController.text);
                if (quantity == null) {
                  showErrorDialog(
                    context,
                    "Parse Error",
                    "Quantity was given a non-integer value (non-number)"
                  );

                  return;
                }

                itemController    .clear();
                urlController     .clear();
                quantityController.clear();

                if (await InventoryManager.addToInventory(name, url, quantity)) {
                  if (context.mounted) {
                    showSuccessDialog(
                      context,
                      "Success!",
                      "Successfully added $name to the Database"
                    );
                  }
                } else {
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      "Database Error",
                      "Error Adding $name to the database"
                    );
                  }
                }

                setState(() {
                  selectedItem = null;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.greenAccent,
              ),
              child: const Text('Submit', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _removeItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: BaseScreenState.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.redAccent, width: 2),
          ),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.redAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                "Remove Item",
                style: TextStyle(color: BaseScreenState.primaryTextColor),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Remove an Item from the Database",
                style: TextStyle(color: BaseScreenState.primaryTextColor)
              ),
              const SizedBox(height: 24),
              DropdownButtonHideUnderline(
                  child: DropdownButton<InventoryItem>(
                    value: selectedItem,
                    hint: const Text(
                      'Select Item',
                      style: TextStyle(color: BaseScreenState.secondaryTextColor),
                    ),
                    dropdownColor: BaseScreenState.surfaceColor,
                    iconEnabledColor: BaseScreenState.primaryTextColor,
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
                          style: const TextStyle(color: BaseScreenState.primaryTextColor),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                if (selectedItem == null) {
                  showErrorDialog(
                    context, 
                    "Error",
                    "No Item Selected"
                  );

                  return;
                }

                if (await InventoryManager.removeItemFromInventory(selectedItem!)) {
                  if (context.mounted) {
                    showSuccessDialog(
                      context,
                      "Success!",
                      "Successfully removed ${selectedItem!.name} from the Database"
                    );
                  }
                } else {
                  if (context.mounted) {
                    showErrorDialog(
                      context,
                      "Database Error",
                      "Error removing ${selectedItem!.name} from the database"
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
              ),
              child: const Text('Remove', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
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
            'Inventory',
            style: TextStyle(
              color: BaseScreenState.primaryTextColor,
              fontSize: 48,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 35,
            children: [
              OutlinedButton(
                onPressed: () => _addItemDialog(context),
                style: OutlinedButton.styleFrom(
                  alignment: AlignmentGeometry.center,
                  side: const BorderSide(color: BaseScreenState.borderColor),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  "Add item",
                  style: TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 16),
                ),
              ),
              OutlinedButton(
                onPressed: () => _removeItemDialog(context),
                style: OutlinedButton.styleFrom(
                  alignment: AlignmentGeometry.center,
                  side: const BorderSide(color: BaseScreenState.borderColor),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  "Remove item",
                  style: TextStyle(color: BaseScreenState.primaryTextColor, fontSize: 16),
                ),
              ),
            ],
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
                      'No items currently added',
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
                        final item = filteredItems[index];
                        
                        return Column(
                          children: [
                            Padding(
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
                                        item.name,
                                        style: const TextStyle(
                                          color: BaseScreenState.primaryTextColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Total: ${item.quantity}',
                                      style: const TextStyle(
                                        color: BaseScreenState.primaryTextColor,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => _showEditDialog(item, context),
                                      child: Icon(Icons.edit, color: BaseScreenState.primaryTextColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
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
