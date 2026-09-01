import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/doctors/domain/doctor_detail_model.dart';
import 'package:meditouch/features/doctors/domain/doctor_model.dart';
import 'package:meditouch/features/doctors/presentation/providers/doctor_detail_provider.dart';

class DoctorDetailScreen extends ConsumerWidget {
  final String doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doctorDetailProvider(doctorId));
    final notifier = ref.read(doctorDetailProvider(doctorId).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    if (state.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
        appBar: const IOS26AppBar(title: 'Doctor Profile'),
        body: const Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    if (state.errorMessage != null || state.doctor == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
        appBar: const IOS26AppBar(title: 'Doctor Profile'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle, size: 42, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Doctor not found',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => notifier.loadDetails(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final doc = state.doctor!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: doc.name,
        actions: [
          IOS26AppBarAction(
            icon: LucideIcons.share2,
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Doctor profile link copied to clipboard')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBookingBar(context, doc, state.selectedTimeslot, isDark),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, topInset + 72, 16, 120),
        children: [
          // 1. Doctor Profile Hero Card
          _buildHeroCard(doc, isDark),
          const SizedBox(height: 16),

          // 2. Key Stats Grid (Experience, Rating, Reviews, Consultations)
          _buildStatsGrid(doc, isDark),
          const SizedBox(height: 16),

          // 3. About Doctor Bio Section
          if (doc.bio != null && doc.bio!.isNotEmpty) ...[
            _buildAboutCard(doc.bio!, isDark),
            const SizedBox(height: 16),
          ],

          // 4. Qualifications & Specializations
          _buildSpecialtiesCard(doc, isDark),
          const SizedBox(height: 16),

          // 5. Hospital Affiliations & Available Days
          _buildHospitalAffiliationsCard(doc, isDark),
          const SizedBox(height: 16),

          // 6. Available Timeslot Selection
          _buildTimeslotsSelectionCard(doc, state, notifier, isDark),
        ],
      ),
    );
  }

  Widget _buildHeroCard(DoctorDetailModel doc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(doc.avatarUrl, doc.name, 72),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        doc.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(LucideIcons.badgeCheck, size: 16, color: Color(0xFF10B981)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  doc.specialties.join(' • '),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B28FD),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'BMDC Reg: ${doc.bmdcRegNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.video, size: 12, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Text(
                        'Instant Video Consultation',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(DoctorDetailModel doc, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            LucideIcons.award,
            '${doc.experienceYears}+ Yrs',
            'Experience',
            const Color(0xFF6B28FD),
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            LucideIcons.star,
            doc.rating.toStringAsFixed(1),
            'Rating',
            const Color(0xFFF59E0B),
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            LucideIcons.messageSquare,
            '${doc.totalReviews}',
            'Reviews',
            const Color(0xFF3B82F6),
            isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            LucideIcons.users,
            '${doc.totalConsultations}+',
            'Patients',
            const Color(0xFF10B981),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(String bio, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.info, size: 16, color: Color(0xFF6B28FD)),
              const SizedBox(width: 6),
              Text(
                'About Doctor',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtiesCard(DoctorDetailModel doc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.graduationCap, size: 16, color: Color(0xFF6B28FD)),
              const SizedBox(width: 6),
              Text(
                'Qualifications & Specialties',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: doc.qualifications.map((q) => _buildBadge(q, isDark)).toList(),
          ),
          if (doc.specialties.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: doc.specialties.map((s) => _buildBadge(s, isDark, isSpecialty: true)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadge(String label, bool isDark, {bool isSpecialty = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSpecialty
            ? const Color(0xFF6B28FD).withValues(alpha: 0.10)
            : (isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F4F6)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSpecialty
              ? const Color(0xFF6B28FD).withValues(alpha: 0.30)
              : (isDark ? Colors.white12 : const Color(0xFFE5E5EA)),
          width: 0.6,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: isSpecialty ? FontWeight.w600 : FontWeight.w500,
          color: isSpecialty
              ? const Color(0xFF6B28FD)
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildHospitalAffiliationsCard(DoctorDetailModel doc, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.building2, size: 16, color: Color(0xFF6B28FD)),
              const SizedBox(width: 6),
              Text(
                'Chambers & Working Days',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (doc.hospitalAffiliations.isNotEmpty)
            ...doc.hospitalAffiliations.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(LucideIcons.check, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        h,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (doc.availableDays.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Available: ${doc.availableDays.join(', ')}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeslotsSelectionCard(
    DoctorDetailModel doc,
    DoctorDetailState state,
    DoctorDetailNotifier notifier,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.calendarClock, size: 16, color: Color(0xFF6B28FD)),
              const SizedBox(width: 6),
              Text(
                'Available Consultation Slots',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (doc.upcomingTimeslots.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                'No upcoming timeslots available for this doctor right now.',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: doc.upcomingTimeslots.map((slot) {
                final isSelected = state.selectedTimeslot?.id == slot.id;
                final dateStr = DateFormat('dd MMM, hh:mm a').format(slot.startTime);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.selectTimeslot(slot);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6B28FD) : (isDark ? Colors.white12 : const Color(0xFFE5E5EA)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 13,
                          color: isSelected ? Colors.white : const Color(0xFF6B28FD),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dateStr,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBookingBar(
    BuildContext context,
    DoctorDetailModel doc,
    TimeslotModel? selectedSlot,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultation Fee',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '৳${doc.consultationFee.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedSlot != null
                        ? 'Selected appointment on ${DateFormat("dd MMM hh:mm a").format(selectedSlot.startTime)}'
                        : 'Selected Dr. ${doc.name}',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B28FD),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Book Video Consult',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(LucideIcons.arrowRight, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? url, String name, double size) {
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: size,
            height: size,
            color: const Color(0xFF6B28FD).withValues(alpha: 0.1),
            child: const Icon(LucideIcons.user, size: 32, color: Color(0xFF6B28FD)),
          ),
          errorWidget: (_, __, ___) => _fallbackAvatar(name, size),
        ),
      );
    }
    return _fallbackAvatar(name, size);
  }

  Widget _fallbackAvatar(String name, double size) {
    final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6B28FD)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isNotEmpty ? initials : 'DR',
        style: GoogleFonts.inter(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
