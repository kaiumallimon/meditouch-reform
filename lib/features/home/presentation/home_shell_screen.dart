import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

          // 2. Pure Floating iOS 26 Glass Pill (No docked background)
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
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
          child: Row(
            children: [
              Expanded(
                child: _IOS26NavItem(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  isDark: isDark,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onItemTapped(0),
                ),
              ),
              Expanded(
                child: _IOS26NavItem(
                  icon: Icons.medication_outlined,
                  selectedIcon: Icons.medication_rounded,
                  label: 'Pharmacy',
                  isSelected: selectedIndex == 1,
                  isDark: isDark,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onItemTapped(1),
                ),
              ),
              Expanded(
                child: _IOS26NavItem(
                  icon: Icons.health_and_safety_outlined,
                  selectedIcon: Icons.health_and_safety_rounded,
                  label: 'Doctors',
                  isSelected: selectedIndex == 2,
                  isDark: isDark,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onItemTapped(2),
                ),
              ),
              Expanded(
                child: _IOS26NavItem(
                  icon: Icons.auto_awesome_outlined,
                  selectedIcon: Icons.auto_awesome_rounded,
                  label: 'AI Chat',
                  isSelected: selectedIndex == 3,
                  isDark: isDark,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onItemTapped(3),
                ),
              ),
              Expanded(
                child: _IOS26NavItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: selectedIndex == 4,
                  isDark: isDark,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onItemTapped(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IOS26NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _IOS26NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.94))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 20,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
