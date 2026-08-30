import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
                // 1. Top Emblem & Header
                Center(
                  child: isDark
                      ? Image.asset(
                          AppAssets.logoDarkPng,
                          width: 170,
                          height: 80,
                          fit: BoxFit.contain,
                        )
                      : SvgPicture.asset(
                          AppAssets.logoSvg,
                          width: 130,
                          height: 65,
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(height: 14),

                Center(
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.youngSerif(
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Create your unified health & medicine account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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
                            style: GoogleFonts.inter(
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

                // 3. Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Personal Information
                      _buildSectionLabel('PERSONAL INFORMATION', isDark),
                      const SizedBox(height: 6),
                      _buildGroupContainer(
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Full Name
                            _buildFormRow(
                              icon: LucideIcons.user,
                              iconBgColor: const Color(0xFF007AFF),
                              isDark: isDark,
                              child: TextFormField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Full name (e.g. John Doe)',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Name must be at least 2 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _buildIndentedDivider(isDark),

                            // Phone Number
                            _buildFormRow(
                              icon: LucideIcons.phone,
                              iconBgColor: const Color(0xFF34C759),
                              isDark: isDark,
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Phone number (e.g. 01712345678)',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (value.trim().length < 10) {
                                    return 'Please enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _buildIndentedDivider(isDark),

                            // Email Address (Optional)
                            _buildFormRow(
                              icon: LucideIcons.mail,
                              iconBgColor: const Color(0xFFFF9500),
                              isDark: isDark,
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email address (optional)',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Security & Credentials
                      _buildSectionLabel('SECURITY & CREDENTIALS', isDark),
                      const SizedBox(height: 6),
                      _buildGroupContainer(
                        isDark: isDark,
                        child: Column(
                          children: [
                            // Password
                            _buildFormRow(
                              icon: LucideIcons.lock,
                              iconBgColor: const Color(0xFF5856D6),
                              isDark: isDark,
                              suffix: InkWell(
                                onTap: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    _obscurePassword
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    size: 17,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Password (min 6 characters)',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please create a password';
                                  }
                                  if (value.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                            ),

                            _buildIndentedDivider(isDark),

                            // Confirm Password
                            _buildFormRow(
                              icon: LucideIcons.shieldCheck,
                              iconBgColor: const Color(0xFFAF52DE),
                              isDark: isDark,
                              suffix: InkWell(
                                onTap: () {
                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    _obscureConfirmPassword
                                        ? LucideIcons.eyeOff
                                        : LucideIcons.eye,
                                    size: 17,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Confirm password',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 13.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
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

                // 4. Primary Create Account Button
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
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
                                style: GoogleFonts.inter(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
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
                        style: GoogleFonts.inter(
                          fontSize: 13,
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
                          style: GoogleFonts.inter(
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
    required Widget child,
    required bool isDark,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
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
          Expanded(child: child),
          if (suffix != null) ...[
            const SizedBox(width: 8),
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

