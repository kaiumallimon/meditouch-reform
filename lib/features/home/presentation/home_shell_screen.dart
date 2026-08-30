import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';

class HomeShellScreen extends StatefulWidget {
  final Widget child;

  const HomeShellScreen({super.key, required this.child});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/pharmacy')) return 1;
    if (location.startsWith('/doctors')) return 2;
    if (location.startsWith('/chatbot')) return 3;
    if (location.startsWith('/settings') || location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.pharmacy);
        break;
      case 2:
        context.go(RouteNames.doctors);
        break;
      case 3:
        context.go(RouteNames.chatbot);
        break;
      case 4:
        context.go(RouteNames.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full Screen Content (passes completely underneath the floating pill)
          Positioned.fill(
            child: widget.child,
          ),

          // 2. Soft Ambient Bottom Fade Gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: (bottomInset > 0 ? bottomInset + 88 : 100),
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? AppColors.darkBackground : AppColors.background).withValues(alpha: 0.0),
                      (isDark ? AppColors.darkBackground : AppColors.background).withValues(alpha: 0.50),
                      (isDark ? AppColors.darkBackground : AppColors.background).withValues(alpha: 0.88),
                      (isDark ? AppColors.darkBackground : AppColors.background),
                    ],
                    stops: const [0.0, 0.40, 0.78, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. Pure Floating iOS 26 Glass Pill with Lucide Icons
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInset > 0 ? bottomInset + 4 : 16,
            child: _IOS26FloatingNavBar(
              selectedIndex: selectedIndex,
              isDark: isDark,
              onItemTapped: (index) => _onItemTapped(index, context),
            ),
          ),
        ],
      ),
    );
  }
}

class _IOS26FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final ValueChanged<int> onItemTapped;

  const _IOS26FloatingNavBar({
    required this.selectedIndex,
    required this.isDark,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final inactiveColor = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280);

    return ClipRRect(
      borderRadius: BorderRadius.circular(38),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 62,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161618).withValues(alpha: 0.72)
                : const Color(0xFFF6F6F8).withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.85),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / 5;

              return Stack(
                children: [
                  // Smooth Gliding Frosted Glass Pill Capsule
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    left: selectedIndex * itemWidth,
                    top: 0,
                    bottom: 0,
                    width: itemWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.16)
                            : Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),

                  // Navigation Tabs Row with Lucide Icons
                  Row(
                    children: [
                      Expanded(
                        child: _IOS26NavItem(
                          icon: LucideIcons.house,
                          label: 'Home',
                          isSelected: selectedIndex == 0,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onItemTapped(0),
                        ),
                      ),
                      Expanded(
                        child: _IOS26NavItem(
                          icon: LucideIcons.pill,
                          label: 'Pharmacy',
                          isSelected: selectedIndex == 1,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onItemTapped(1),
                        ),
                      ),
                      Expanded(
                        child: _IOS26NavItem(
                          icon: LucideIcons.stethoscope,
                          label: 'Doctors',
                          isSelected: selectedIndex == 2,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onItemTapped(2),
                        ),
                      ),
                      Expanded(
                        child: _IOS26NavItem(
                          icon: LucideIcons.sparkles,
                          label: 'AI Chat',
                          isSelected: selectedIndex == 3,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onItemTapped(3),
                        ),
                      ),
                      Expanded(
                        child: _IOS26NavItem(
                          icon: LucideIcons.settings,
                          label: 'Settings',
                          isSelected: selectedIndex == 4,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                          onTap: () => onItemTapped(4),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _IOS26NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _IOS26NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 19,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2.5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
