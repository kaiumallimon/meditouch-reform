import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditouch/core/constants/app_assets.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/storage/secure_storage.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _haloAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance reveal animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeIn,
      ),
    );

    // 2. Ambient breathing pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _haloAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _entranceController.forward();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final storage = ref.read(secureStorageServiceProvider);
    final token = await storage.getAccessToken();

    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      context.go(RouteNames.home);
    } else {
      context.go(RouteNames.login);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Atmospheric Breathing Ambient Halo
            AnimatedBuilder(
              animation: _haloAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _haloAnimation.value,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          (isDark ? AppColors.primaryDark : AppColors.primary)
                              .withValues(alpha: isDark ? 0.22 : 0.14),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.75],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 2. Freely Floating Logo & Tagline
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Mark
                      isDark
                          ? Image.asset(
                              AppAssets.logoDarkPng,
                              width: 230,
                              height: 140,
                              fit: BoxFit.contain,
                            )
                          : SvgPicture.asset(
                              AppAssets.logoSvg,
                              width: 160,
                              height: 95,
                              fit: BoxFit.contain,
                            ),
                      const SizedBox(height: 14),

                      // Refined Category Pill Tagline
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2E).withValues(alpha: 0.50)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : const Color(0xFFE5E5EA),
                            width: 0.75,
                          ),
                        ),
                        child: Text(
                          'TELEMEDICINE & PHARMACY',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: isDark
                                ? const Color(0xFF98989F)
                                : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Floating Bottom Loading Indicator
            Positioned(
              bottom: 40,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CupertinoActivityIndicator(
                  radius: 11,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
