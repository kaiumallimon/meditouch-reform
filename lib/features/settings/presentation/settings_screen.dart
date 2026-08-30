import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditouch/app/theme_provider.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/storage/secure_storage.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        title: Text(
          'Settings',
          style: GoogleFonts.youngSerif(
            fontSize: 19,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
          children: [
            // 1. Profile Account Card (Top Tile linking to ProfileScreen)
            Material(
              color: isDark ? AppColors.darkSurface : Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: InkWell(
                onTap: () => context.push(RouteNames.profile),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.primaryLight,
                        child: Icon(
                          Icons.person_rounded,
                          color: isDark ? Colors.white : AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Profile',
                              style: GoogleFonts.youngSerif(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Personal details, address & medical history',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            // 2. Appearance Section (iOS Dark Mode Switching - Zero Tint)
            _SectionHeader(title: 'APPEARANCE & DISPLAY', isDark: isDark),
            const SizedBox(height: 8),
            Material(
              color: isDark ? AppColors.darkSurface : Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceElevated
                            : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: isDark
                            ? Colors.white
                            : AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Dark Mode',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      themeMode == ThemeMode.system
                          ? 'Automatic (System)'
                          : themeMode == ThemeMode.dark
                              ? 'On'
                              : 'Off',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                    trailing: CupertinoSwitch(
                      value: isDark,
                      activeTrackColor: CupertinoColors.activeGreen,
                      onChanged: (val) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                  ),
                  ListTile(
                    title: Text(
                      'Theme Option',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: themeMode,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                        dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Automatic'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                        onChanged: (mode) {
                          if (mode != null) {
                            ref.read(themeModeProvider.notifier).setThemeMode(mode);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. Healthcare Shortcuts Section
            _SectionHeader(title: 'HEALTHCARE & ORDERS', isDark: isDark),
            const SizedBox(height: 8),
            Material(
              color: isDark ? AppColors.darkSurface : Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Prescription Orders',
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.orders),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                  ),
                  _SettingsTile(
                    icon: Icons.video_call_outlined,
                    title: 'Telemedicine Consultations',
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.appointments),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications & Dosage Reminders',
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.notifications),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 4. Preferences & About Section
            _SectionHeader(title: 'PREFERENCES & ABOUT', isDark: isDark),
            const SizedBox(height: 8),
            Material(
              color: isDark ? AppColors.darkSurface : Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Privacy & Data Protection',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About MediTouch v1.0',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 5. Sign Out Button
            OutlinedButton.icon(
              onPressed: () async {
                final storage = ref.read(secureStorageServiceProvider);
                await storage.clearAll();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.errorDark, size: 18),
              label: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.errorDark : AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: (isDark ? AppColors.errorDark : AppColors.error).withValues(alpha: 0.3),
                ),
                backgroundColor: isDark ? AppColors.darkSurface : const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppColors.darkTextSecondary : AppColors.primary,
        size: 20,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
