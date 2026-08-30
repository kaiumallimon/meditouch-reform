import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
          indicatorColor: isDark ? AppColors.primaryDarkLight : AppColors.primaryLight,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: activeColor),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.medication_outlined),
              selectedIcon: Icon(Icons.medication_rounded, color: activeColor),
              label: 'Pharmacy',
            ),
            NavigationDestination(
              icon: const Icon(Icons.health_and_safety_outlined),
              selectedIcon: Icon(Icons.health_and_safety_rounded, color: activeColor),
              label: 'Doctors',
            ),
            NavigationDestination(
              icon: const Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded, color: activeColor),
              label: 'AI Chat',
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: activeColor),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
