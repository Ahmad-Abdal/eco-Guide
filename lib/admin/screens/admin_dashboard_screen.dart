import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/dashboard_providers.dart';
import 'add_store_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color cardFill = Color(0xFFF3EEDD);

  String buildGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData iconForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.productAdded:
        return Icons.inventory_2_outlined;
      case ActivityType.productUpdated:
        return Icons.edit_outlined;
      case ActivityType.productScanned:
        return Icons.qr_code_scanner_rounded;
      case ActivityType.userJoined:
        return Icons.person_add_alt_1_outlined;
    }
  }

  void openAddStoreScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStoreScreen()),
    );
  }

  void showSelectStoreSheet(BuildContext context, List<StoreOverview> stores) {
    if (stores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a store first, then add products to it.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFDF9F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select store',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 12),
                for (final store in stores)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.storefront_rounded,
                        color: vibrantGreen),
                    title: Text(
                      store.name,
                      style: const TextStyle(color: darkText),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to the Add product form for
                      // this store.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Add product form for ${store.name} goes here',
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final storesAsync = ref.watch(storesOverviewProvider);
    final activityAsync = ref.watch(recentActivityProvider);
    final adminName = ref.watch(adminDisplayNameProvider);

    return RefreshIndicator(
      color: vibrantGreen,
      onRefresh: () async {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(storesOverviewProvider);
        ref.invalidate(recentActivityProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        children: [
          Text(
            '${buildGreeting()}, ${adminName ?? 'Admin'} ',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's your EcoWise overview.",
            style: TextStyle(
              fontSize: 14,
              color: darkTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          statsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: CircularProgressIndicator(color: vibrantGreen),
              ),
            ),
            error: (error, stack) => const Text(
              'Could not load dashboard stats.',
              style: TextStyle(color: darkText),
            ),
            data: (stats) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.65,
              children: [
                buildStatCard(
                  icon: Icons.storefront_rounded,
                  label: 'Stores',
                  value: '${stats.storeCount}',
                ),
                buildStatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Products',
                  value: '${stats.productCount}',
                ),
                buildStatCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Users',
                  value: '${stats.userCount}',
                ),
                buildStatCard(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'Scans',
                  value: '${stats.scanCount}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildActionButton(
                  icon: Icons.add_business_rounded,
                  label: 'Add store',
                  filled: true,
                  onTap: () => openAddStoreScreen(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildActionButton(
                  icon: Icons.add_box_outlined,
                  label: 'Add product',
                  filled: false,
                  onTap: () {
                    final stores = storesAsync.maybeWhen(
                      data: (data) => data,
                      orElse: () => <StoreOverview>[],
                    );
                    showSelectStoreSheet(context, stores);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),
          const Text(
            'Recent activity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 12),
          activityAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(color: vibrantGreen),
              ),
            ),
            error: (error, stack) => const Text(
              'Could not load recent activity.',
              style: TextStyle(color: darkText),
            ),
            data: (activities) {
              if (activities.isEmpty) {
                return buildEmptyState(
                  icon: Icons.history_rounded,
                  message: 'Nothing has happened yet — activity will show up here.',
                );
              }
              return Column(
                children: [
                  for (final activity in activities)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardFill,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              iconForActivity(activity.type),
                              color: darkTeal,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  activity.title,
                                  style: const TextStyle(
                                    color: darkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (activity.subtitle != null)
                                  Text(
                                    activity.subtitle!,
                                    style: const TextStyle(
                                      color: darkTeal,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            activity.timeAgo,
                            style: TextStyle(
                              color: darkTeal.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: darkTeal.withOpacity(0.6), size: 30),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: darkTeal.withOpacity(0.8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardFill,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: vibrantGreen, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
              height: 1.1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: darkTeal,
              fontWeight: FontWeight.w500,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: filled
          ? ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: vibrantGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onTap,
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: darkTeal, width: 1.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onTap,
              icon: const Icon(Icons.add, color: darkTeal, size: 20),
              label: Text(
                label,
                style: const TextStyle(
                  color: darkTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}