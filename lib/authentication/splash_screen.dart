import 'package:flutter/material.dart';
import '../user/screens/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Updated Color Palette
  static const Color pureWhite = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF6B6B6B);
  static const Color primaryGreen = Color(0xFF1B7A43);
  static const Color lightGreenBg = Color(0xFFE7F4EC);
  static const Color borderGray = Color(0xFFE0E0E0);
  static const Color sectionFill = Color(0xFFF7F8F6);

  late List<AnimationController> leafControllers;
  late List<Animation<double>> leafAnimations;

  final List<LeafConfig> leafConfigs = const [
    LeafConfig(top: 40, left: 20, size: 42, duration: 3200, delay: 0),
    LeafConfig(top: 30, right: 30, size: 34, duration: 2600, delay: 300),
    LeafConfig(top: 220, right: 15, size: 38, duration: 3600, delay: 600),
    LeafConfig(bottom: 220, left: 10, size: 40, duration: 3000, delay: 200),
    LeafConfig(bottom: 180, right: 25, size: 32, duration: 2800, delay: 500),
  ];

  @override
  void initState() {
    super.initState();

    leafControllers = leafConfigs
        .map(
          (config) => AnimationController(
            vsync: this,
            duration: Duration(milliseconds: config.duration),
          )..repeat(reverse: true),
        )
        .toList();

    // Bigger float range: -40 to 40 instead of -10 to 10, full top-bottom drift
    leafAnimations = leafControllers
        .map(
          (controller) => Tween<double>(begin: -40, end: 40).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOut),
          ),
        )
        .toList();

    for (var i = 0; i < leafControllers.length; i++) {
      Future.delayed(Duration(milliseconds: leafConfigs[i].delay), () {
        if (mounted) leafControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in leafControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildFloatingLeaf(int index) {
    final config = leafConfigs[index];
    return AnimatedBuilder(
      animation: leafAnimations[index],
      builder: (context, child) {
        return Positioned(
          top: config.top,
          bottom: config.bottom,
          left: config.left,
          right: config.right,
          child: Transform.translate(
            offset: Offset(0, leafAnimations[index].value),
            child: Opacity(
              opacity: 0.65,
              child: Icon(
                Icons.eco_rounded,
                size: config.size,
                color: primaryGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lightGreenBg,
        border: Border.all(color: borderGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.15),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Icons.eco_rounded,
              size: 64,
              color: primaryGreen,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      body: SafeArea(
        child: Stack(
          children: [
            for (var i = 0; i < leafConfigs.length; i++) buildFloatingLeaf(i),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildLogo(),
                      const SizedBox(height: 20),
                      Text(
                        'EcoWise',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Better Choice, Green Future.',
                        style: TextStyle(
                          fontSize: 14,
                          color: textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: sectionFill,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderGray, width: 1),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeafConfig {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final int duration;
  final int delay;

  const LeafConfig({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.duration,
    required this.delay,
  });
}