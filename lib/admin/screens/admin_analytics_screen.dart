import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => AdminAnalyticsScreenState();
}

class AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color darkGreen = Color(0xFF0F5C30);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color sectionFill = Color(0xFFF7F8F6);

  static const categoryBarColors = [primaryGreen, darkGreen, Color(0xFF3E9B5E), Color(0xFF7FBF9A)];

  String selectedPeriod = 'Today';

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsSnapshotProvider);

    return Scaffold(
      backgroundColor: pureWhite,
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async => ref.invalidate(analyticsSnapshotProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Analytics', style: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold)),
                buildPeriodDropdown(),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Filtering by period needs timestamped activity data, coming with scan/view tracking.',
              style: TextStyle(color: textGray.withOpacity(0.7), fontSize: 11.5, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 22),

            analyticsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator(color: primaryGreen)),
              ),
              error: (e, s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('Could not load analytics.\n$e', textAlign: TextAlign.center, style: const TextStyle(color: textDark)),
              ),
              data: (snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top stat row ──
                  Row(
                    children: [
                      Expanded(child: buildStatCard('Users', '${snapshot.userCount}', Icons.people_alt_rounded, real: true)),
                      const SizedBox(width: 12),
                      Expanded(child: buildStatCard('Scans', '—', Icons.qr_code_scanner_rounded, real: false)),
                      const SizedBox(width: 12),
                      Expanded(child: buildStatCard('Products', '${snapshot.productCount}', Icons.inventory_2_outlined, real: true)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── User Activity chart ──
                  sectionTitle('User Activity'),
                  const SizedBox(height: 12),
                  buildActivityChartCard(hasData: false),
                  const SizedBox(height: 28),

                  // ── Scan Activity ──
                  sectionTitle('Scan Activity'),
                  const SizedBox(height: 12),
                  buildEmptyMetricsCard(
                    icon: Icons.qr_code_scanner_rounded,
                    message: 'No scan data yet — wire the scan screen to log events to see totals here.',
                    metrics: const [('Total Scans', '—'), ('Successful Scans', '—')],
                  ),
                  const SizedBox(height: 28),

                  // ── Most Popular Categories (real) ──
                  sectionTitle('Most Popular Categories'),
                  const SizedBox(height: 12),
                  buildCategoryBreakdown(snapshot.categoryBreakdown),
                  const SizedBox(height: 28),

                  // ── Top Products (real, by eco score) ──
                  sectionTitle('Top Rated Products'),
                  const SizedBox(height: 4),
                  Text(
                    'Ranked by Eco Score — view/scan-based ranking will replace this once tracked.',
                    style: TextStyle(color: textGray.withOpacity(0.7), fontSize: 11.5, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 12),
                  buildTopProducts(snapshot.topRatedProducts),
                  const SizedBox(height: 28),

                  // ── Recommendation Performance ──
                  sectionTitle('Recommendation Performance'),
                  const SizedBox(height: 12),
                  buildEmptyMetricsCard(
                    icon: Icons.auto_awesome_rounded,
                    message: 'No click-tracking yet — needs impressions/clicks logged on the recommendation feed.',
                    metrics: const [('Shown', '—'), ('Clicked', '—'), ('Click Rate', '—')],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPeriodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: sectionFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderGray),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryGreen, size: 18),
          style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w600),
          dropdownColor: pureWhite,
          items: const ['Today', 'This Week', 'This Month']
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) => setState(() => selectedPeriod = value ?? 'Today'),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold));
  }

  Widget buildStatCard(String label, String value, IconData icon, {required bool real}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGray),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: real ? lightGreenBg : sectionFill, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: real ? primaryGreen : textGray.withOpacity(0.6), size: 16),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(color: real ? textDark : textGray.withOpacity(0.6), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget buildActivityChartCard({required bool hasData}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGray),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            width: double.infinity,
            child: hasData
                ? CustomPaint(painter: _ActivityChartPainter(primaryGreen, darkGreen))
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.25,
                        child: CustomPaint(
                          size: const Size(double.infinity, 140),
                          painter: _ActivityChartPainter(primaryGreen, darkGreen, placeholder: true),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: sectionFill, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          'No activity data yet',
                          style: TextStyle(color: textGray.withOpacity(0.8), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                .map((d) => Text(d, style: TextStyle(color: textGray.withOpacity(0.7), fontSize: 11)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyMetricsCard({
    required IconData icon,
    required String message,
    required List<(String, String)> metrics,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: sectionFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGray),
      ),
      child: Column(
        children: [
          Row(
            children: metrics
                .map((m) => Expanded(
                      child: Column(
                        children: [
                          Text(m.$2, style: TextStyle(color: textGray.withOpacity(0.6), fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(m.$1, style: const TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(icon, size: 16, color: textGray.withOpacity(0.6)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message, style: TextStyle(color: textGray.withOpacity(0.75), fontSize: 11.5, height: 1.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCategoryBreakdown(List<CategoryShare> breakdown) {
    if (breakdown.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: sectionFill, borderRadius: BorderRadius.circular(18)),
        child: Text('No products yet.', style: TextStyle(color: textGray.withOpacity(0.7))),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGray),
      ),
      child: Column(
        children: breakdown.take(6).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final share = entry.value;
          final color = categoryBarColors[index % categoryBarColors.length];
          return Padding(
            padding: EdgeInsets.only(bottom: index == breakdown.length - 1 ? 0 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(share.category, style: const TextStyle(color: textDark, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('${share.percent.toStringAsFixed(0)}%', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: share.percent / 100,
                    minHeight: 8,
                    backgroundColor: sectionFill,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildTopProducts(List topProducts) {
    if (topProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: sectionFill, borderRadius: BorderRadius.circular(18)),
        child: Text('No products yet.', style: TextStyle(color: textGray.withOpacity(0.7))),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGray),
      ),
      child: Column(
        children: topProducts.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text('${index + 1}', style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: textDark, fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: lightGreenBg, borderRadius: BorderRadius.circular(10)),
                  child: Text('${product.ecoScore}', style: const TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Draws a smooth filled line chart in green tones. When [placeholder] is
/// true it draws a generic illustrative wave (since there's no real
/// weekly activity data yet) — used faded behind the "No activity data
/// yet" label so the space still reads as a chart, not a blank box.
class _ActivityChartPainter extends CustomPainter {
  final Color lightColor;
  final Color darkColor;
  final bool placeholder;

  _ActivityChartPainter(this.lightColor, this.darkColor, {this.placeholder = false});

  @override
  void paint(Canvas canvas, Size size) {
    final points = placeholder
        ? [0.5, 0.62, 0.4, 0.7, 0.55, 0.8, 0.6]
        : [0.3, 0.45, 0.35, 0.6, 0.5, 0.75, 0.65];

    final path = Path();
    final stepX = size.width / (points.length - 1);

    for (var i = 0; i < points.length; i++) {
      final x = stepX * i;
      final y = size.height * (1 - points[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = stepX * (i - 1);
        final prevY = size.height * (1 - points[i - 1]);
        final midX = (prevX + x) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [darkColor.withOpacity(0.25), lightColor.withOpacity(0.02)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final strokePaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ActivityChartPainter oldDelegate) => false;
}