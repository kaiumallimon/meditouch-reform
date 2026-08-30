import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/storage/secure_storage.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryLight,
                    child: const Icon(Icons.person, color: AppColors.primary, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Account',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'patient@meditouch.com',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ProfileTile(
              icon: Icons.receipt_long_outlined,
              title: 'Prescription Orders',
              onTap: () => context.push(RouteNames.orders),
            ),
            _ProfileTile(
              icon: Icons.calendar_month_outlined,
              title: 'My Consultations',
              onTap: () => context.push(RouteNames.appointments),
            ),
            _ProfileTile(
              icon: Icons.payment_outlined,
              title: 'Payment Methods & bKash',
              onTap: () {},
            ),
            _ProfileTile(
              icon: Icons.security_outlined,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                final storage = ref.read(secureStorageServiceProvider);
                await storage.clearAll();
                if (context.mounted) {
                  context.go(RouteNames.login);
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.errorLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18),
        onTap: onTap,
      ),
    );
  }
}

