import 'package:flutter/material.dart';
import 'package:icons_management_system/data/inventory_manager.dart';
import 'package:icons_management_system/data/inventory_transaction.dart';
import 'package:icons_management_system/screens/base_screen.dart';

enum AnalyticsRange { sevenDays, thirtyDays, ninetyDays, allTime }

class AnalyticsScreen extends BaseScreen {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => AnalyticsScreenState();
}

class AnalyticsScreenState extends BaseScreenState<AnalyticsScreen> {
  AnalyticsRange selectedRange = AnalyticsRange.thirtyDays;

  static void navigate(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
    );
  }

  List<InventoryTransaction> get filteredTransactions {
    final now = DateTime.now();

    switch (selectedRange) {
      case AnalyticsRange.sevenDays:
        return InventoryManager.transactions
            .where((tx) => now.difference(tx.timestamp) <= const Duration(days: 7))
            .toList();
      case AnalyticsRange.thirtyDays:
        return InventoryManager.transactions
            .where((tx) => now.difference(tx.timestamp) <= const Duration(days: 30))
            .toList();
      case AnalyticsRange.ninetyDays:
        return InventoryManager.transactions
            .where((tx) => now.difference(tx.timestamp) <= const Duration(days: 90))
            .toList();
      case AnalyticsRange.allTime:
        return InventoryManager.transactions;
    }
  }

  int get totalCheckouts =>
      filteredTransactions.where((tx) => tx.type == "checkout").length;

  int get totalReturns =>
      filteredTransactions.where((tx) => tx.type == "return").length;

  int get uniqueUsers =>
      filteredTransactions.map((tx) => tx.studentId).toSet().length;

  int get itemsCurrentlyOut =>
      InventoryManager.inventory.values.fold(0, (sum, items) => sum + items.length);

  Map<String, int> get itemCheckoutCounts {
    final Map<String, int> counts = {};
    for (final tx in filteredTransactions.where((tx) => tx.type == "checkout")) {
      counts[tx.itemName] = (counts[tx.itemName] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get userCheckoutCounts {
    final Map<String, int> counts = {};
    for (final tx in filteredTransactions.where((tx) => tx.type == "checkout")) {
      counts[tx.userName] = (counts[tx.userName] ?? 0) + 1;
    }
    return counts;
  }

  Map<int, int> get hourlyCheckoutCounts {
    final Map<int, int> counts = {};
    for (final tx in filteredTransactions.where((tx) => tx.type == "checkout")) {
      counts[tx.timestamp.hour] = (counts[tx.timestamp.hour] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get dailyActivityCounts {
    final Map<String, int> counts = {};
    for (final tx in filteredTransactions) {
      final key =
          "${tx.timestamp.year}-${tx.timestamp.month.toString().padLeft(2, '0')}-${tx.timestamp.day.toString().padLeft(2, '0')}";
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget buildContent(BuildContext context) {
    final topItems = itemCheckoutCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topUsers = userCheckoutCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topHours = hourlyCheckoutCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final activityByDay = dailyActivityCounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final recentActivity = filteredTransactions.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 72, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Analytics",
            style: TextStyle(
              color: BaseScreenState.primaryTextColor,
              fontSize: 40,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: BaseScreenState.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BaseScreenState.borderColor),
            ),
            child: DropdownButton<AnalyticsRange>(
              value: selectedRange,
              dropdownColor: BaseScreenState.surfaceColor,
              underline: const SizedBox(),
              style: const TextStyle(color: BaseScreenState.primaryTextColor),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRange = value;
                  });
                }
              },
              items: const [
                DropdownMenuItem(
                  value: AnalyticsRange.sevenDays,
                  child: Text("Last 7 Days"),
                ),
                DropdownMenuItem(
                  value: AnalyticsRange.thirtyDays,
                  child: Text("Last 30 Days"),
                ),
                DropdownMenuItem(
                  value: AnalyticsRange.ninetyDays,
                  child: Text("Last 90 Days"),
                ),
                DropdownMenuItem(
                  value: AnalyticsRange.allTime,
                  child: Text("All Time"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _metricCard("Total Checkouts", totalCheckouts.toString()),
              _metricCard("Total Returns", totalReturns.toString()),
              _metricCard("Unique Users", uniqueUsers.toString()),
              _metricCard("Items Currently Out", itemsCurrentlyOut.toString()),
            ],
          ),

          const SizedBox(height: 32),

          _sectionCard(
            title: "Most Popular Items",
            children: topItems.isEmpty
                ? [_emptyText("No checkout data in this interval.")]
                : topItems.take(8).map((entry) {
                    return _rowText(entry.key, entry.value.toString());
                  }).toList(),
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: "Most Active Users",
            children: topUsers.isEmpty
                ? [_emptyText("No user activity in this interval.")]
                : topUsers.take(8).map((entry) {
                    return _rowText(entry.key, entry.value.toString());
                  }).toList(),
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: "Peak Checkout Hours",
            children: topHours.isEmpty
                ? [_emptyText("No hourly checkout data in this interval.")]
                : topHours.take(8).map((entry) {
                    final label = "${entry.key.toString().padLeft(2, '0')}:00";
                    return _rowText(label, entry.value.toString());
                  }).toList(),
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: "Activity by Day",
            children: activityByDay.isEmpty
                ? [_emptyText("No daily activity in this interval.")]
                : activityByDay.take(12).map((entry) {
                    return _rowText(entry.key, entry.value.toString());
                  }).toList(),
          ),

          const SizedBox(height: 20),

          _sectionCard(
            title: "Recent Activity",
            children: recentActivity.isEmpty
                ? [_emptyText("No recent activity in this interval.")]
                : recentActivity.take(12).map((tx) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        "${tx.type.toUpperCase()} • ${tx.itemName} • ${tx.userName} (#${tx.studentId}) • ${tx.timestamp}",
                        style: const TextStyle(
                          color: BaseScreenState.primaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BaseScreenState.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BaseScreenState.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: BaseScreenState.secondaryTextColor,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: BaseScreenState.primaryTextColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BaseScreenState.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BaseScreenState.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BaseScreenState.primaryTextColor,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _rowText(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(
                color: BaseScreenState.primaryTextColor,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            right,
            style: const TextStyle(
              color: BaseScreenState.secondaryTextColor,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: BaseScreenState.secondaryTextColor,
        fontSize: 15,
      ),
    );
  }
}