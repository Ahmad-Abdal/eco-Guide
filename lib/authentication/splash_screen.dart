import 'package:flutter/material.dart';
import '../user/screens/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Custom Color Palette based on design specs
  static const Color appBackground = Color(0xFFFDF9F0);
  static const Color darkText = Color(0xFF2F4F4F);
  static const Color vibrantGreen = Color(0xFF24AC5D);
  static const Color darkTeal = Color(0xFF1C7043);

  late List<AnimationController> leafControllers;
  late List<Animation<double>> leafAnimations;

  final List<LeafConfig> leafConfigs = const [
    LeafConfig(top: 40, left: 20, size: 34, duration: 3200, delay: 0),
    LeafConfig(top: 30, right: 30, size: 26, duration: 2600, delay: 300),
    LeafConfig(top: 220, right: 15, size: 30, duration: 3600, delay: 600),
    LeafConfig(bottom: 220, left: 10, size: 32, duration: 3000, delay: 200),
    LeafConfig(bottom: 180, right: 25, size: 24, duration: 2800, delay: 500),
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

    leafAnimations = leafControllers
        .map(
          (controller) => Tween<double>(begin: -10, end: 10).animate(
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
              opacity: 0.7,
              child: Icon(
                Icons.eco_rounded,
                size: config.size,
                color: vibrantGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [vibrantGreen, Color(0xFF8AEB86)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(
              Icons.eco_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
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
                      const SizedBox(height: 16),
                      const Text(
                        'EcoWise',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Better Choice, Green Future.',
                        style: TextStyle(
                          fontSize: 14,
                          color: darkTeal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vibrantGreen,
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
                    ],
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