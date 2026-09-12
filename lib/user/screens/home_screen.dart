import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/home_providers.dart';
import '../providers/profile_providers.dart';
import 'sign_in_screen.dart';

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);
  static const Color cardFill = Color(0xFFF3EEDD);

  static const categories = [
    'Sustainable Fashion',
    'Organic Food',
    'Recycled Materials',
    'Zero Waste',
  ];

  void openProfileDialog(BuildContext context, WidgetRef ref, UserProfile? profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDF9F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: cardFill,
                backgroundImage: (profile?.avatarUrl != null)
                    ? NetworkImage(profile!.avatarUrl!)
                    : null,
                child: profile?.avatarUrl == null
                    ? const Icon(Icons.person, color: darkTeal, size: 32)
                    : null,
              ),
              const SizedBox(height: 14),
              Text(
                profile?.name ?? 'EcoWise user',
                style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              if (profile?.city != null) ...[
                const SizedBox(height: 4),
                Text(profile!.city!, style: const TextStyle(color: darkTeal, fontSize: 13)),
              ],
              if (profile?.bio != null) ...[
                const SizedBox(height: 10),
                Text(
                  profile!.bio!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: darkText, fontSize: 13),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent, width: 1.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await Supabase.instance.client.auth.signOut();
                    if (!context.mounted) return;
                    Navigator.of(context).pop(); // close dialog
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                  label: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecoScoreAsync = ref.watch(userEcoScoreProvider);
    final productsAsync = ref.watch(recommendedProductsProvider);
    final displayName = ref.watch(userDisplayNameProvider);
    final profileAsync = ref.watch(currentProfileProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: vibrantGreen),
              child: const Icon(Icons.eco_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            const Text('EcoWise', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 20)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: cardFill, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.notifications_none_rounded, color: darkTeal, size: 24),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => openProfileDialog(context, ref, profileAsync.value),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: cardFill,
                backgroundImage: (profileAsync.value?.avatarUrl != null)
                    ? NetworkImage(profileAsync.value!.avatarUrl!)
                    : null,
                child: profileAsync.value?.avatarUrl == null
                    ? const Icon(Icons.person, color: darkTeal, size: 24)
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Text(
          'Hello, ${displayName ?? 'there'}!',
          style: const TextStyle(color: darkText, fontSize: 30, fontWeight: FontWeight.bold, height: 1.1),
        ),
        const SizedBox(height: 16),
        ecoScoreAsync.when(
          loading: () => const SizedBox(height: 44),
          error: (e, s) => const SizedBox.shrink(),
          data: (score) => Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(color: vibrantGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.eco_rounded, color: vibrantGreen, size: 24),
                const SizedBox(width: 10),
                Text(
                  score != null ? 'Your Eco-Score: $score/100' : 'Eco-Score: not calculated yet',
                  style: const TextStyle(color: vibrantGreen, fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) => Chip(
              label: Text(categories[index], style: const TextStyle(color: darkTeal, fontSize: 13, fontWeight: FontWeight.w600)),
              backgroundColor: cardFill,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: const [
            Icon(Icons.auto_awesome_rounded, color: vibrantGreen, size: 22),
            SizedBox(width: 8),
            Text('Top Recommendations for You', style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 19)),
          ],
        ),
        const SizedBox(height: 16),
        productsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: vibrantGreen)),
          ),
          error: (e, s) => const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Could not load recommendations.', style: TextStyle(color: darkText)),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No products yet.', style: TextStyle(color: darkTeal.withOpacity(0.7), fontSize: 15)),
                ),
              );
            }
            return Column(
              children: products.map((p) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: cardFill, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          p.imageUrl,
                          width: 62,
                          height: 62,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 62,
                            height: 62,
                            color: Colors.white,
                            child: const Icon(Icons.inventory_2_outlined, color: darkTeal, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: darkText, fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('\$${p.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: darkTeal, fontWeight: FontWeight.w700, fontSize: 13)),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: vibrantGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                                    child: Text('${p.ecoScore}/100 Eco',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: vibrantGreen, fontSize: 10, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {
                          // TODO: navigate to product detail screen
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: vibrantGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}