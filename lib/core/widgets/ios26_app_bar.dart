import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';

class IOS26AppBarAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final int? badgeCount;
  final bool isDestructive;

  const IOS26AppBarAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badgeCount,
    this.isDestructive = false,
  });
}

class IOS26AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<IOS26AppBarAction> actions;
  final VoidCallback? onBack;
  final bool showBack;
  final Color? backgroundColor;

  const IOS26AppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
    this.onBack,
    this.showBack = false,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64.0 : 56.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7);
    final effectiveBg = backgroundColor ?? defaultBg;

    return Container(
      color: effectiveBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Optional Leading / Back Button
              if (showBack) ...[
                _buildBackButton(context, isDark),
                const SizedBox(width: 12),
              ] else if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],

              // Title and Subtitle
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.youngSerif(
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Liquid Glass Action Capsule (iOS 26)
              if (actions.isNotEmpty) _buildLiquidGlassActionCapsule(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return InkWell(
      onTap: onBack ?? () => Navigator.of(context).maybePop(),
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.9),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                LucideIcons.chevronLeft,
                size: 17,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidGlassActionCapsule(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.95),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(actions.length, (index) {
              final action = actions[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0)
                    Container(
                      width: 0.8,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : const Color(0xFFE5E5EA),
                    ),
                  _buildActionItem(action, isDark),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildActionItem(IOS26AppBarAction action, bool isDark) {
    return Tooltip(
      message: action.tooltip ?? '',
      child: InkWell(
        onTap: action.onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                action.icon,
                size: 17,
                color: action.isDestructive
                    ? const Color(0xFFFF453A)
                    : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              ),
              if (action.badgeCount != null && action.badgeCount! > 0)
                Positioned(
                  top: -2,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        width: 1,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${action.badgeCount}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
