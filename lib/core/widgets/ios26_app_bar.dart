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
  final Widget? leading;
  final List<IOS26AppBarAction> actions;
  final VoidCallback? onBack;
  final bool showBack;
  final bool? centerTitle;
  final Color? backgroundColor;

  const IOS26AppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.onBack,
    this.showBack = false,
    this.centerTitle,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(54.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ?? (isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7));
    final shouldCenter = centerTitle ?? (showBack || leading != null);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bg,
            bg.withValues(alpha: 0.90),
            bg.withValues(alpha: 0.50),
            bg.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.45, 0.80, 1.0],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: shouldCenter
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // Center Title
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56.0),
                        child: Center(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.youngSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Left Leading / Back Button
                    if (showBack)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildBackButton(context, isDark),
                      )
                    else if (leading != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: leading!,
                      ),

                    // Right Action Capsule
                    if (actions.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildLiquidGlassActionCapsule(isDark),
                      ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showBack) ...[
                      _buildBackButton(context, isDark),
                      const SizedBox(width: 12),
                    ] else if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.youngSerif(
                          fontSize: 21,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
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
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E).withValues(alpha: 0.80)
                  : Colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.22)
                    : Colors.white.withValues(alpha: 0.95),
                width: 0.9,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                LucideIcons.chevronLeft,
                size: 18,
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
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2C2E).withValues(alpha: 0.82)
                : Colors.white.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.24)
                  : Colors.white.withValues(alpha: 0.95),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
                      height: 20,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
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
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(
                action.icon,
                size: 18,
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
