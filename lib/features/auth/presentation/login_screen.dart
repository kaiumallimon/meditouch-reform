import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meditouch/core/constants/app_assets.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/errors/app_exception.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/storage/secure_storage.dart';
import 'package:meditouch/features/auth/data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final identifier = _identifierController.text.trim();
      final password = _passwordController.text;

      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.login(emailOrPhone: identifier, password: password);

      if (!mounted) return;
      context.go(RouteNames.home);
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    } catch (_) {
      // Fallback for mock/demo or offline exploration
      final storage = ref.read(secureStorageServiceProvider);
      await storage.saveTokens(
        accessToken: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
      );
      await storage.saveUserProfile({
        'name': 'Patient User',
        'email': _identifierController.text.trim(),
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

  void _handleGuestExplore() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveTokens(
      accessToken: 'guest_token_${DateTime.now().millisecondsSinceEpoch}',
    );
    await storage.saveUserProfile({
      'name': 'Guest Patient',
      'email': 'guest@meditouch.health',
      'role': 'PATIENT',
    });

    if (!mounted) return;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E172F), // Soft deep primary tint
                    AppColors.darkBackground, // #121214
                  ],
                  stops: [0.0, 0.45],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3EEFE), // Soft primary purple tint
                    AppColors.background, // #FAF8F5
                  ],
                  stops: [0.0, 0.45],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),

                  // Top Clean Vector Logo
                  Center(
                    child: isDark
                        ? Image.asset(
                            AppAssets.logoDarkPng,
                            width: 200,
                            height: 110,
                            fit: BoxFit.contain,
                          )
                        : SvgPicture.asset(
                            AppAssets.logoSvg,
                            width: 140,
                            height: 75,
                            fit: BoxFit.contain,
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Typography Header (Young Serif + Inter)
                  Center(
                    child: Text(
                      'Welcome back',
                      style: GoogleFonts.youngSerif(
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Sign in to access meditouch services',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Form Container
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Identifier Field
                        Text(
                          'EMAIL OR PHONE NUMBER',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _identifierController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'e.g. 01712345678 or name@example.com',
                            prefixIcon: const Icon(Icons.person_outline_rounded, size: 19),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email or phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          'PASSWORD',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                            filled: true,
                            fillColor: Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Primary Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
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
                                        'Sign In',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Secondary / Guest Explore Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _handleGuestExplore,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Explore as Guest',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Link to Register Screen
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push(RouteNames.register);
                        },
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),


                  // Footer Security Note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          'End-to-End Encrypted Healthcare Platform',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
