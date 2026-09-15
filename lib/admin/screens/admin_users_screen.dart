import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../user/providers/profile_providers.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminUsersScreen> createState() => AdminUsersScreenState();
}

class AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color sectionFill = Color(0xFFF7F8F6);

  final searchController = TextEditingController();
  String query = '';

  static const avatarPalette = [
    Color(0xFF1B7A43),
    Color(0xFF2FA362),
    Color(0xFF0E8A6E),
    Color(0xFF3E9B5E),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Color avatarColorFor(String seed) {
    final index = seed.codeUnits.fold<int>(0, (sum, c) => sum + c) % avatarPalette.length;
    return avatarPalette[index];
  }

  String formatJoined(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget buildAvatar(UserProfile user, {double radius = 26}) {
    final color = avatarColorFor(user.id);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withOpacity(0.14),
      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
      child: user.avatarUrl == null
          ? Text(
              initialsFor(user.name),
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: radius * 0.6),
            )
          : null,
    );
  }

  void openUserSheet(UserProfile user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: pureWhite,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: borderGray, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 20),
                // ── Profile header block ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen, avatarColorFor(user.id)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null
                            ? Text(initialsFor(user.name), style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18))
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            if (user.email != null) ...[
                              const SizedBox(height: 2),
                              Text(user.email!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white.withOpacity(0.85)),
                                const SizedBox(width: 4),
                                Text('Joined ${formatJoined(user.createdAt)}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── ACTIVITY / INTERESTS / RECENT ACTIVITY ──────────
                // These need a user_product_interactions table (scans,
                // product views, wishlist adds) which doesn't exist yet
                // — there are no active users generating that data.
                // Once built, swap the placeholder card below for:
                //
                // sectionCard('ACTIVITY', [
                //   statRow(Icons.qr_code_scanner_rounded, 'Scans', '${stats.scanCount}'),
                //   statRow(Icons.visibility_outlined, 'Product Views', '${stats.viewCount}'),
                //   statRow(Icons.favorite_border_rounded, 'Wishlist', '${stats.wishlistCount}'),
                // ]),
                // sectionCard('INTERESTS', [
                //   statRow(Icons.category_outlined, 'Favorite Category', stats.topCategory),
                //   statRow(Icons.eco_outlined, 'Favorite Material', stats.topMaterial),
                //   statRow(Icons.trending_up_rounded, 'Avg Eco Score', '${stats.avgEcoScore}'),
                // ]),
                // sectionCard('RECENT ACTIVITY', [
                //   for (final item in stats.recentProducts) bulletRow(item),
                // ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: sectionFill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderGray),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: lightGreenBg),
                          child: Icon(Icons.insights_rounded, color: primaryGreen.withOpacity(0.7), size: 26),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Activity & interests coming soon',
                          style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No interaction data yet — scans, views, and wishlist activity will appear here once users start browsing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: textGray.withOpacity(0.85), fontSize: 12.5, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: pureWhite,
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async => ref.invalidate(allUsersProvider),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Hero header ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 26),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryGreen, Color(0xFF2FA362)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.18)),
                        child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Users', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('Manage user activity & interests',
                                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      usersAsync.maybeWhen(
                        data: (users) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(14)),
                          child: Text('${users.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => setState(() => query = value.trim().toLowerCase()),
                      style: const TextStyle(color: textDark),
                      decoration: InputDecoration(
                        hintText: 'Search users...',
                        hintStyle: TextStyle(color: textGray.withOpacity(0.7), fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: primaryGreen),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              child: usersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: primaryGreen)),
                ),
                error: (e, s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('Could not load users.\n$e', textAlign: TextAlign.center, style: const TextStyle(color: textDark)),
                ),
                data: (users) {
                  final filtered = query.isEmpty
                      ? users
                      : users.where((u) =>
                          u.name.toLowerCase().contains(query) ||
                          (u.email?.toLowerCase().contains(query) ?? false)).toList();

                  if (filtered.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: sectionFill),
                              child: Icon(Icons.people_outline_rounded, size: 34, color: textGray.withOpacity(0.5)),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              users.isEmpty ? 'No registered users yet.' : 'No users match your search.',
                              style: TextStyle(color: textGray.withOpacity(0.8), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filtered.map((user) {
                      final color = avatarColorFor(user.id);
                      return GestureDetector(
                        onTap: () => openUserSheet(user),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: pureWhite,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: borderGray),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Row(
                            children: [
                              buildAvatar(user),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 15)),
                                    if (user.email != null) ...[
                                      const SizedBox(height: 2),
                                      Text(user.email!, style: const TextStyle(color: textGray, fontSize: 13)),
                                    ],
                                    const SizedBox(height: 8),
                                    // ── Scans / Views / Wishlist badges ──
                                    // Needs the same interaction-tracking
                                    // table as the detail sheet. Re-enable
                                    // once it exists:
                                    //
                                    // Row(children: [
                                    //   miniStat(Icons.qr_code_scanner_rounded, '${stats.scanCount}'),
                                    //   miniStat(Icons.visibility_outlined, '${stats.viewCount}'),
                                    //   miniStat(Icons.favorite_border_rounded, '${stats.wishlistCount}'),
                                    // ]),
                                    // Text('Favorite: ${stats.topCategory}'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.calendar_today_rounded, size: 10, color: color),
                                          const SizedBox(width: 4),
                                          Text('Joined ${formatJoined(user.createdAt)}',
                                              style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: textGray.withOpacity(0.5)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}