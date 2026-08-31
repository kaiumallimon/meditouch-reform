import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/auth/data/auth_repository.dart';
import 'package:meditouch/features/auth/domain/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;

    final name = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Patient User';
    final email = (user?.email != null && user!.email!.isNotEmpty) ? user.email! : 'Not provided';
    final phone = (user?.phone != null && user!.phone!.isNotEmpty) ? user.phone! : 'Not provided';
    final gender = (user?.gender != null && user!.gender!.isNotEmpty) ? user.gender! : 'Not specified';
    final bloodGroup = (user?.bloodGroup != null && user!.bloodGroup!.isNotEmpty) ? user.bloodGroup! : 'Not specified';
    final address = (user?.defaultAddress != null && user!.defaultAddress!.isNotEmpty) ? user.defaultAddress! : 'Not provided';
    final postalCode = (user?.postalCode != null && user!.postalCode!.isNotEmpty) ? user.postalCode! : 'Not specified';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Personal Profile',
        showBack: true,
        actions: [
          IOS26AppBarAction(
            icon: LucideIcons.pencil,
            tooltip: 'Edit Profile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile edit mode is enabled'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16, topInset + 72, 16, 40),
        children: [
          // 1. Hero Profile Island Card
          _buildHeroProfileCard(context, user, isDark),
          const SizedBox(height: 24),

          // 2. Personal Information Section
          _buildSectionLabel('PERSONAL INFORMATION', isDark),
          const SizedBox(height: 6),
          _buildGroupContainer(
            isDark: isDark,
            child: Column(
              children: [
                _IOSProfileFieldTile(
                  icon: LucideIcons.user,
                  iconBgColor: const Color(0xFF007AFF),
                  label: 'Full Name',
                  value: name,
                  isDark: isDark,
                ),
                _buildIndentedDivider(isDark),
                _IOSProfileFieldTile(
                  icon: LucideIcons.phone,
                  iconBgColor: const Color(0xFF34C759),
                  label: 'Phone Number',
                  value: phone,
                  isDark: isDark,
                ),
                _buildIndentedDivider(isDark),
                _IOSProfileFieldTile(
                  icon: LucideIcons.mail,
                  iconBgColor: const Color(0xFF5856D6),
                  label: 'Email',
                  value: email,
                  isDark: isDark,
                ),
                _buildIndentedDivider(isDark),
                _IOSProfileFieldTile(
                  icon: LucideIcons.users,
                  iconBgColor: const Color(0xFFFF9500),
                  label: 'Gender',
                  value: gender,
                  isDark: isDark,
                ),
                _buildIndentedDivider(isDark),
                _IOSProfileFieldTile(
                  icon: LucideIcons.droplet,
                  iconBgColor: const Color(0xFFFF3B30),
                  label: 'Blood Group',
                  value: bloodGroup,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Delivery & Address Section
          _buildSectionLabel('DELIVERY & ADDRESS', isDark),
          const SizedBox(height: 6),
          _buildGroupContainer(
            isDark: isDark,
            child: Column(
              children: [
                _IOSProfileFieldTile(
                  icon: LucideIcons.mapPin,
                  iconBgColor: const Color(0xFF30B0C7),
                  label: 'Default Address',
                  value: address,
                  isDark: isDark,
                ),
                _buildIndentedDivider(isDark),
                _IOSProfileFieldTile(
                  icon: LucideIcons.mailbox,
                  iconBgColor: const Color(0xFFAF52DE),
                  label: 'Postal Code',
                  value: postalCode,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 4. Edit Profile Button
          Container(
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.primaryDark : AppColors.primary)
                      .withValues(alpha: isDark ? 0.35 : 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile edit mode is enabled'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(LucideIcons.pencil, size: 16),
              label: Text(
                'Edit Profile Information',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 5. Security Footer Branding
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.shieldCheck,
                  size: 13,
                  color: isDark ? const Color(0xFF48484A) : const Color(0xFFA1A1AA),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'MediTouch • Secure & Encrypted Records',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF48484A) : const Color(0xFFA1A1AA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroProfileCard(BuildContext context, UserModel? user, bool isDark) {
    final displayName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Patient User';
    final displayEmail = (user?.email != null && user!.email!.isNotEmpty)
        ? user.email!
        : (user?.phone != null && user!.phone!.isNotEmpty ? user.phone! : 'No contact info provided');
    final hasBlood = user?.bloodGroup != null && user!.bloodGroup!.isNotEmpty;
    final hasAddress = user?.defaultAddress != null && user!.defaultAddress!.isNotEmpty;

    return _buildGroupContainer(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Profile Avatar with Gradient Ring & Camera Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 76,
                  height: 76,
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
                            borderRadius: BorderRadius.circular(38),
                            child: Image.network(
                              user.avatarUrl!,
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                LucideIcons.user,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          )
                        : const Icon(
                            LucideIcons.user,
                            color: Colors.white,
                            size: 34,
                          ),
                  ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Change photo tapped'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : const Color(0xFFE5E5EA),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        LucideIcons.camera,
                        size: 13,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Account Name & Status Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.youngSerif(
                      fontSize: 20,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF13281C)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E5032)
                          : const Color(0xFFA7F3D0),
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    user?.role ?? 'PATIENT',
                    style: GoogleFonts.inter(
                      fontSize: 8.5,
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
            const SizedBox(height: 3),

            // Email / Phone subtitle
            Text(
              displayEmail,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
            if (hasBlood || hasAddress) ...[
              const SizedBox(height: 16),
              // Quick Stats Capsule Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasBlood)
                    _buildStatPill(
                      icon: LucideIcons.droplet,
                      iconColor: const Color(0xFFFF3B30),
                      label: 'Blood: ${user.bloodGroup}',
                      isDark: isDark,
                    ),
                  if (hasBlood && hasAddress) const SizedBox(width: 8),
                  if (hasAddress)
                    _buildStatPill(
                      icon: LucideIcons.mapPin,
                      iconColor: const Color(0xFF30B0C7),
                      label: user.defaultAddress!,
                      isDark: isDark,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE5E5EA),
          width: 0.7,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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

class _IOSProfileFieldTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final String value;
  final bool isDark;

  const _IOSProfileFieldTile({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    size: 15,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Field Label
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),

              // Field Value
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}
