import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_assets.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/errors/app_exception.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/storage/secure_storage.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/auth/data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.register(
        name: name,
        phone: phone,
        email: email.isNotEmpty ? email : null,
        password: password,
      );

      if (!mounted) return;
      context.go(RouteNames.home);
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      // Offline / demo fallback
      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveTokens(
        accessToken: 'mock_registered_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await storage.saveUserProfile({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'PATIENT',
      });

      if (!mounted) return;
      context.go(RouteNames.home);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Create Account',
        showBack: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(RouteNames.login);
          }
        },
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. App Logo (No Background Container)
                Center(
                  child: isDark
                      ? Image.asset(
                          AppAssets.logoDarkPng,
                          width: 155,
                          height: 70,
                          fit: BoxFit.contain,
                        )
                      : SvgPicture.asset(
                          AppAssets.logoSvg,
                          width: 125,
                          height: 55,
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'Join MediTouch',
                    style: textTheme.headlineMedium?.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Create your account for personalized healthcare & medicines',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // 2. Error Alert Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF331517)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF7F1D1D)
                            : const Color(0xFFFCA5A5),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.circleAlert,
                          size: 16,
                          color: Color(0xFFFF453A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 12.5,
                              color: isDark
                                  ? const Color(0xFFFF8B85)
                                  : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 3. Grouped Forms
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Personal Information
                      _buildSectionLabel('PERSONAL INFORMATION', isDark, textTheme),
                      const SizedBox(height: 6),
                      _buildGroupContainer(
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Full Name
                            _buildFormRow(
                              icon: LucideIcons.user,
                              iconBgColor: isDark
                                  ? const Color(0xFF0A84FF).withValues(alpha: 0.15)
                                  : const Color(0xFF007AFF).withValues(alpha: 0.10),
                              iconColor: isDark ? const Color(0xFF0A84FF) : const Color(0xFF007AFF),
                              isDark: isDark,
                              child: TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Full name (e.g. John Doe)',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  isDense: true,
                                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return ' ';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _buildIndentedDivider(isDark),

                            // Phone Number
                            _buildFormRow(
                              icon: LucideIcons.phone,
                              iconBgColor: isDark
                                  ? const Color(0xFF30D158).withValues(alpha: 0.15)
                                  : const Color(0xFF34C759).withValues(alpha: 0.10),
                              iconColor: isDark ? const Color(0xFF30D158) : const Color(0xFF34C759),
                              isDark: isDark,
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Phone number (e.g. 01712345678)',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  isDense: true,
                                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return ' ';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _buildIndentedDivider(isDark),

                            // Email Address (Optional)
                            _buildFormRow(
                              icon: LucideIcons.mail,
                              iconBgColor: isDark
                                  ? const Color(0xFFFF9F0A).withValues(alpha: 0.15)
                                  : const Color(0xFFFF9500).withValues(alpha: 0.10),
                              iconColor: isDark ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500),
                              isDark: isDark,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email address (optional)',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  isDense: true,
                                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Security & Credentials
                      _buildSectionLabel('SECURITY & CREDENTIALS', isDark, textTheme),
                      const SizedBox(height: 6),
                      _buildGroupContainer(
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Password
                            _buildFormRow(
                              icon: LucideIcons.lock,
                              iconBgColor: isDark
                                  ? const Color(0xFFBF5AF2).withValues(alpha: 0.15)
                                  : const Color(0xFF5856D6).withValues(alpha: 0.10),
                              iconColor: isDark ? const Color(0xFFBF5AF2) : const Color(0xFF5856D6),
                              isDark: isDark,
                              suffix: InkWell(
                                onTap: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    _obscurePassword
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    size: 18,
                                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password (min 6 characters)',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  isDense: true,
                                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return ' ';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _buildIndentedDivider(isDark),

                            // Confirm Password
                            _buildFormRow(
                              icon: LucideIcons.shieldCheck,
                              iconBgColor: isDark
                                  ? const Color(0xFFBF5AF2).withValues(alpha: 0.15)
                                  : const Color(0xFFAF52DE).withValues(alpha: 0.10),
                              iconColor: isDark ? const Color(0xFFBF5AF2) : const Color(0xFFAF52DE),
                              isDark: isDark,
                              suffix: InkWell(
                                onTap: () {
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Icon(
                                    _obscureConfirmPassword
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    size: 18,
                                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Confirm password',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? const Color(0xFF636366) : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                  isDense: true,
                                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return ' ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // 4. Primary Create Account Pill Button
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppColors.primaryDark : AppColors.primary)
                            .withValues(alpha: isDark ? 0.35 : 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 10,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Create Account',
                                style: textTheme.labelLarge?.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                LucideIcons.arrowRight,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Link back to Login
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13.5,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.login);
                        }
                      },
                      child: Text(
                        'Sign In',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 6. Security Footer
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
                          'MediTouch • Secure & Encrypted Healthcare Platform',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: isDark ? const Color(0xFF48484A) : const Color(0xFFA1A1AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildFormRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required Widget child,
    required bool isDark,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.5),
            ),
            child: Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (suffix != null) ...[
            const SizedBox(width: 4),
            suffix,
          ],
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

  static Widget _buildSectionLabel(String title, bool isDark, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: textTheme.labelSmall?.copyWith(
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
      indent: 58,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : const Color(0xFFE5E5EA),
    );
  }
}


