import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/app/theme_provider.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/storage/secure_storage.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/auth/data/auth_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    final isGuest = user == null || user.isGuest;

    final topInset = MediaQuery.paddingOf(context).top;

    final profileName = isGuest
        ? 'Guest User'
        : ((user.name.isNotEmpty) ? user.name : 'My Profile');
    final profileSubtitle = isGuest
        ? 'Sign in to access health records & pharmacy'
        : ((user.email != null && user.email!.isNotEmpty)
            ? user.email!
            : (user.phone != null && user.phone!.isNotEmpty
                ? user.phone!
                : 'Personal details, address & medical history'));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: const IOS26AppBar(
        title: 'Settings',
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16, topInset + 72, 16, 96),
        children: [
          // 1. iOS 26 Apple-ID Profile Island
          _buildGroupContainer(
            isDark: isDark,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(RouteNames.profile),
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      // Profile Avatar with Status Ring
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isDark
                                ? const [Color(0xFF3A3A3C), Color(0xFF2C2C2E)]
                                : const [Color(0xFF5B15FC), Color(0xFF7C3AED)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(26),
                                  child: Image.network(
                                    user.avatarUrl!,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      LucideIcons.user,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  LucideIcons.user,
                                  color: Colors.white,
                                  size: 24,
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    profileName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.youngSerif(
                                      fontSize: 16,
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF13281C)
                                        : const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF1E5032)
                                          : const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Text(
                                    user?.role ?? 'VERIFIED',
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? const Color(0xFF30D158)
                                          : const Color(0xFF059669),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              profileSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                        LucideIcons.chevronRight,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFFC7C7CC),
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
            const SizedBox(height: 24),

            // 2. Appearance Section (iOS 26 Display & Theme Island)
            _buildSectionLabel('APPEARANCE & DISPLAY', isDark),
            const SizedBox(height: 6),
            _buildGroupContainer(
              isDark: isDark,
              child: Column(
                children: [
                  _IOSSettingsTile(
                    icon: isDark ? LucideIcons.moon : LucideIcons.sun,
                    iconBgColor: isDark ? const Color(0xFF5E5CE6) : const Color(0xFFFF9F0A),
                    title: 'Dark Mode',
                    subtitle: themeMode == ThemeMode.system
                        ? 'Automatic (System)'
                        : themeMode == ThemeMode.dark
                            ? 'Always On'
                            : 'Off',
                    isDark: isDark,
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
                  _buildIndentedDivider(isDark),
                  _IOSSettingsTile(
                    icon: LucideIcons.palette,
                    iconBgColor: const Color(0xFFBF5AF2),
                    title: 'Theme Option',
                    isDark: isDark,
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
            const SizedBox(height: 24),

            // 3. Healthcare Shortcuts Island
            _buildSectionLabel('HEALTHCARE & ORDERS', isDark),
            const SizedBox(height: 6),
            _buildGroupContainer(
              isDark: isDark,
              child: Column(
                children: [
                  _IOSSettingsTile(
                    icon: LucideIcons.fileText,
                    iconBgColor: const Color(0xFF007AFF),
                    title: 'Prescription Orders',
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.orders),
                  ),
                  _buildIndentedDivider(isDark),
                  _IOSSettingsTile(
                    icon: LucideIcons.video,
                    iconBgColor: const Color(0xFF34C759),
                    title: 'Telemedicine Consultations',
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.appointments),
                  ),
                  _buildIndentedDivider(isDark),
                  _IOSSettingsTile(
                    icon: LucideIcons.bell,
                    iconBgColor: const Color(0xFFFF3B30),
                    title: 'Notifications & Reminders',
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.notifications),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Privacy & System Info Island
            _buildSectionLabel('PREFERENCES & ABOUT', isDark),
            const SizedBox(height: 6),
            _buildGroupContainer(
              isDark: isDark,
              child: Column(
                children: [
                  _IOSSettingsTile(
                    icon: LucideIcons.shieldCheck,
                    iconBgColor: const Color(0xFF32ADE6),
                    title: 'Privacy & Data Protection',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildIndentedDivider(isDark),
                  _IOSSettingsTile(
                    icon: LucideIcons.info,
                    iconBgColor: const Color(0xFF8E8E93),
                    title: 'About MediTouch v1.0',
                    isDark: isDark,
                    trailing: Text(
                      'iOS 26 Edition',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),

            // 5. iOS 26 Action Island (Sign Out if logged in, Sign In if guest)
            if (isGuest) ...[
              _buildGroupContainer(
                isDark: isDark,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(RouteNames.login),
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            LucideIcons.logIn,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign In / Create Account',
                            style: GoogleFonts.inter(
                              color: isDark ? AppColors.primaryDark : AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              _buildGroupContainer(
                isDark: isDark,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      final storage = ref.read(secureStorageServiceProvider);
                      await storage.clearAll();
                      if (context.mounted) {
                        context.go(RouteNames.login);
                      }
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.logOut,
                            color: Color(0xFFFF453A),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFFF453A),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // iOS 26 Footer Branding
            Center(
              child: Text(
                'MediTouch Health • Powered by Gemini Clinical AI',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  color: isDark ? const Color(0xFF48484A) : const Color(0xFFA1A1AA),
                ),
              ),
            ),
          ],
        ),
    );
  }

  static Widget _buildGroupContainer({
    required Widget child,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: child,
      ),
    );
  }

  static Widget _buildSectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.7,
          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
        ),
      ),
    );
  }

  static Widget _buildIndentedDivider(bool isDark) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      indent: 52,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFE5E5EA),
    );
  }
}

class _IOSSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _IOSSettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    required this.isDark,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              // Squircle Icon Badge
              Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(7.5),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing Action or Chevron
              trailing ??
                  Icon(
                    LucideIcons.chevronRight,
                    color: isDark
                        ? AppColors.darkTextMuted
                        : const Color(0xFFC7C7CC),
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
