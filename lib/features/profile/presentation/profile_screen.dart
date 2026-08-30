import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';

import 'package:meditouch/core/widgets/ios26_app_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Personal Profile',
        subtitle: 'Medical History & Identity',
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Avatar & Name Card
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.primaryLight,
                    child: Icon(
                      LucideIcons.user,
                      color: isDark ? Colors.white : AppColors.primary,
                      size: 44,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Text(
                'Patient Account',
                style: GoogleFonts.youngSerif(
                  fontSize: 19,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Center(
              child: Text(
                'patient@meditouch.health',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Information Cards
            _buildInfoCard(
              context: context,
              isDark: isDark,
              title: 'PERSONAL INFORMATION',
              items: [
                _InfoRow(label: 'Full Name', value: 'Patient User', isDark: isDark),
                _InfoRow(label: 'Phone Number', value: '+880 1712-345678', isDark: isDark),
                _InfoRow(label: 'Email', value: 'patient@meditouch.health', isDark: isDark),
                _InfoRow(label: 'Gender', value: 'Not specified', isDark: isDark),
                _InfoRow(label: 'Blood Group', value: 'O+', isDark: isDark),
              ],
            ),
            const SizedBox(height: 16),

            _buildInfoCard(
              context: context,
              isDark: isDark,
              title: 'DELIVERY & ADDRESS',
              items: [
                _InfoRow(label: 'Default Address', value: 'Dhaka, Bangladesh', isDark: isDark),
                _InfoRow(label: 'Postal Code', value: '1212', isDark: isDark),
              ],
            ),
            const SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile edit mode is enabled'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.primary,
                foregroundColor: Colors.white,
                side: isDark ? const BorderSide(color: AppColors.darkBorder) : null,
              ),
              icon: const Icon(LucideIcons.pencil, size: 15),
              label: const Text('Edit Profile Information'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required List<_InfoRow> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
            ),
            itemBuilder: (_, index) => items[index],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
