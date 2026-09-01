import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/doctors/domain/doctor_model.dart';
import 'package:meditouch/features/doctors/presentation/providers/doctors_provider.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet(BuildContext context, DoctorsState state, DoctorsNotifier notifier) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DoctorFilterBottomSheet(
        currentState: state,
        onApply: (minFee, maxFee, minExp, minRating, sortBy) {
          notifier.applyAdvancedFilters(
            minFee: minFee,
            maxFee: maxFee,
            minExperience: minExp,
            minRating: minRating,
            sortBy: sortBy,
          );
        },
        onReset: () {
          notifier.resetFilters();
        },
      ),
    );
  }

  IconData _getSpecialtyIcon(String specialty) {
    final lower = specialty.toLowerCase();
    if (lower.contains('cardio')) return LucideIcons.heartPulse;
    if (lower.contains('derma') || lower.contains('skin') || lower.contains('cosmet')) return LucideIcons.sparkles;
    if (lower.contains('pedia') || lower.contains('child')) return LucideIcons.baby;
    if (lower.contains('neuro') || lower.contains('brain')) return LucideIcons.activity;
    if (lower.contains('gyn') || lower.contains('women') || lower.contains('obs')) return LucideIcons.shieldCheck;
    if (lower.contains('ortho') || lower.contains('bone')) return LucideIcons.bone;
    if (lower.contains('psych') || lower.contains('mental')) return LucideIcons.smile;
    if (lower.contains('eye') || lower.contains('ophthal')) return LucideIcons.eye;
    if (lower.contains('ent') || lower.contains('ear')) return LucideIcons.ear;
    return LucideIcons.stethoscope;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorsProvider);
    final notifier = ref.read(doctorsProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Find Doctors',
        actions: [
          IOS26AppBarAction(
            icon: LucideIcons.calendar,
            tooltip: 'My Appointments',
            onPressed: () => context.push(RouteNames.appointments),
          ),
          IOS26AppBarAction(
            icon: LucideIcons.slidersHorizontal,
            tooltip: 'Filter & Sort',
            badgeCount: state.hasActiveFilters ? 1 : null,
            onPressed: () => _openFilterBottomSheet(context, state, notifier),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.init(),
        edgeOffset: topInset + 64,
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(14, topInset + 72, 14, 100),
          children: [
            // 1. iOS 26 Liquid Glass Search Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2C2C2E).withValues(alpha: 0.60)
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.14)
                          : const Color(0xFFE5E5EA),
                      width: 0.8,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => notifier.onSearchChanged(val),
                      textAlignVertical: TextAlignVertical.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        hintText: 'Search doctor, specialty, hospital...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 17,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                  notifier.onSearchChanged('');
                                },
                                child: Icon(
                                  LucideIcons.x,
                                  size: 16,
                                  color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Specialty Filter Capsules Row
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: state.specialties.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final isSelected = isAll
                      ? (state.selectedSpecialty == null || state.selectedSpecialty!.isEmpty)
                      : state.selectedSpecialty == state.specialties[index - 1].specialty;

                  final title = isAll ? 'All Specialists' : state.specialties[index - 1].specialty;
                  final icon = isAll ? LucideIcons.stethoscope : _getSpecialtyIcon(title);
                  final count = isAll ? state.total : state.specialties[index - 1].doctorCount;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.selectSpecialty(isAll ? null : title);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected
                            ? null
                            : (isDark
                                ? const Color(0xFF2C2C2E).withValues(alpha: 0.60)
                                : Colors.white.withValues(alpha: 0.85)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6B28FD)
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFE5E5EA)),
                          width: isSelected ? 1.2 : 0.8,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6B28FD).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 14,
                            color: isSelected ? Colors.white : (isDark ? const Color(0xFF9E86FF) : const Color(0xFF6B28FD)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark ? AppColors.darkTextMuted : AppColors.textMuted),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 3. Featured Doctors Carousel
            if (state.featuredDoctors.isNotEmpty && state.searchQuery.isEmpty && (state.selectedSpecialty == null || state.selectedSpecialty!.isEmpty)) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.sparkles, size: 16, color: Color(0xFF9E86FF)),
                      const SizedBox(width: 6),
                      Text(
                        'Top Recommended Doctors',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Verified Specialists',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 146,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.featuredDoctors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final doc = state.featuredDoctors[index];
                    return _FeaturedDoctorCard(doctor: doc, isDark: isDark);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 4. Section Title & Doctor Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.isLoading
                      ? 'Searching Doctors...'
                      : '${state.total} Verified Specialist${state.total == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => _openFilterBottomSheet(context, state, notifier),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.arrowUpDown,
                        size: 13,
                        color: isDark ? const Color(0xFF9E86FF) : const Color(0xFF6B28FD),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSortLabel(state.sortBy),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF9E86FF) : const Color(0xFF6B28FD),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. Main Doctors List
            if (state.isLoading && state.doctors.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CupertinoActivityIndicator(radius: 14)),
              )
            else if (state.doctors.isEmpty)
              _buildEmptyState(isDark, notifier)
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = state.doctors[index];
                  return _DoctorCard(doctor: doc, isDark: isDark);
                },
              ),

            // 6. Pagination Controls
            if (state.totalPages > 1) ...[
              const SizedBox(height: 24),
              _buildPaginationControls(state, notifier, isDark),
            ],
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'fee_asc':
        return 'Price: Low-High';
      case 'fee_desc':
        return 'Price: High-Low';
      case 'experience_desc':
        return 'Experience';
      case 'consultations_desc':
      case 'popular':
        return 'Most Consults';
      case 'name_asc':
        return 'Name A-Z';
      case 'rating_desc':
      default:
        return 'Top Rated';
    }
  }

  Widget _buildEmptyState(bool isDark, DoctorsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E).withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6B28FD).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.userX, size: 36, color: Color(0xFF6B28FD)),
          ),
          const SizedBox(height: 14),
          Text(
            'No Doctors Found',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try adjusting your search keywords, specialty filters, or fee range.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              _searchController.clear();
              notifier.resetFilters();
            },
            icon: const Icon(LucideIcons.rotateCcw, size: 14),
            label: const Text('Reset All Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B28FD),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(DoctorsState state, DoctorsNotifier notifier, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: state.page > 1 ? () => notifier.goToPage(state.page - 1) : null,
          icon: const Icon(LucideIcons.chevronLeft, size: 18),
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        Text(
          'Page ${state.page} of ${state.totalPages}',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        IconButton(
          onPressed: state.page < state.totalPages ? () => notifier.goToPage(state.page + 1) : null,
          icon: const Icon(LucideIcons.chevronRight, size: 18),
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Featured Doctor Card (Horizontal Carousel)
// ---------------------------------------------------------------------------
class _FeaturedDoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final bool isDark;

  const _FeaturedDoctorCard({required this.doctor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final specialty = doctor.specialties.isNotEmpty ? doctor.specialties.first : 'Specialist';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/doctors/${doctor.id}');
      },
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildDoctorAvatar(doctor.avatarUrl, doctor.name, 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.badgeCheck, size: 14, color: Color(0xFF10B981)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        specialty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B28FD),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${doctor.experienceYears} yrs exp',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 12, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 3),
                    Text(
                      doctor.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      ' (${doctor.totalReviews})',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '৳${doctor.consultationFee.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main Doctor List Card (iOS 26 High-End Glassmorphic Card)
// ---------------------------------------------------------------------------
class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final bool isDark;

  const _DoctorCard({required this.doctor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primarySpecialty = doctor.specialties.isNotEmpty ? doctor.specialties.first : 'General Specialist';
    final qualificationsStr = doctor.qualifications.join(', ');
    final hospitalStr = doctor.hospitalAffiliations.isNotEmpty ? doctor.hospitalAffiliations.first : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/doctors/${doctor.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Avatar + Name + BMDC + Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _buildDoctorAvatar(doctor.avatarUrl, doctor.name, 56),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctor.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.badgeCheck, size: 15, color: Color(0xFF10B981)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        primarySpecialty,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B28FD),
                        ),
                      ),
                      if (qualificationsStr.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          qualificationsStr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            if (hospitalStr != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.building2,
                      size: 12,
                      color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        hospitalStr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 0.8,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA),
            ),
            const SizedBox(height: 10),

            // Row 2: Stats (Exp, Rating, Fee) + Book Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.star, size: 13, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${doctor.totalReviews}) • ${doctor.experienceYears}y exp',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${doctor.consultationFee.toInt()} / consultation',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/doctors/${doctor.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B28FD),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Book Slot',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronRight, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildDoctorAvatar(String? url, String name, double size) {
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
          child: const Icon(LucideIcons.user, size: 22, color: Color(0xFF6B28FD)),
        ),
        errorWidget: (_, __, ___) => _fallbackDoctorAvatar(name, size),
      ),
    );
  }
  return _fallbackDoctorAvatar(name, size);
}

Widget _fallbackDoctorAvatar(String name, double size) {
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

// ---------------------------------------------------------------------------
// Doctor Filter Bottom Sheet Modal
// ---------------------------------------------------------------------------
class _DoctorFilterBottomSheet extends StatefulWidget {
  final DoctorsState currentState;
  final Function(double? minFee, double? maxFee, int? minExp, double? minRating, String? sortBy) onApply;
  final VoidCallback onReset;

  const _DoctorFilterBottomSheet({
    required this.currentState,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_DoctorFilterBottomSheet> createState() => _DoctorFilterBottomSheetState();
}

class _DoctorFilterBottomSheetState extends State<_DoctorFilterBottomSheet> {
  late RangeValues _feeRange;
  int? _minExp;
  double? _minRating;
  late String _sortBy;

  @override
  void initState() {
    super.initState();
    _feeRange = RangeValues(
      widget.currentState.minFee ?? 0.0,
      widget.currentState.maxFee ?? 2000.0,
    );
    _minExp = widget.currentState.minExperience;
    _minRating = widget.currentState.minRating;
    _sortBy = widget.currentState.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort Doctors',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sort By Chips
            Text(
              'Sort By',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _sortChip('Top Rated', 'rating_desc', isDark),
                _sortChip('Price: Low-High', 'fee_asc', isDark),
                _sortChip('Price: High-Low', 'fee_desc', isDark),
                _sortChip('Experience', 'experience_desc', isDark),
                _sortChip('Most Consults', 'consultations_desc', isDark),
                _sortChip('Name A-Z', 'name_asc', isDark),
              ],
            ),
            const SizedBox(height: 18),

            // Fee Range Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consultation Fee Range',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  '৳${_feeRange.start.toInt()} - ৳${_feeRange.end.toInt()}',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B28FD),
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _feeRange,
              min: 0,
              max: 2000,
              divisions: 20,
              activeColor: const Color(0xFF6B28FD),
              inactiveColor: isDark ? Colors.white12 : const Color(0xFFE5E5EA),
              onChanged: (vals) {
                setState(() => _feeRange = vals);
              },
            ),
            const SizedBox(height: 14),

            // Experience Filter Chips
            Text(
              'Minimum Clinical Experience',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _expChip('Any', null, isDark),
                _expChip('5+ yrs', 5, isDark),
                _expChip('10+ yrs', 10, isDark),
                _expChip('15+ yrs', 15, isDark),
              ],
            ),
            const SizedBox(height: 18),

            // Minimum Rating Filter Chips
            Text(
              'Minimum Star Rating',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _ratingChip('Any', null, isDark),
                _ratingChip('4.0+ ⭐', 4.0, isDark),
                _ratingChip('4.5+ ⭐', 4.5, isDark),
                _ratingChip('4.8+ ⭐', 4.8, isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final minFee = _feeRange.start > 0 ? _feeRange.start : null;
                  final maxFee = _feeRange.end < 2000 ? _feeRange.end : null;
                  widget.onApply(minFee, maxFee, _minExp, _minRating, _sortBy);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B28FD),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Apply Filters',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value, bool isDark) {
    final selected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _sortBy = value);
      },
      selectedColor: const Color(0xFF6B28FD),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide.none,
    );
  }

  Widget _expChip(String label, int? value, bool isDark) {
    final selected = _minExp == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _minExp = value);
      },
      selectedColor: const Color(0xFF6B28FD),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide.none,
    );
  }

  Widget _ratingChip(String label, double? value, bool isDark) {
    final selected = _minRating == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) setState(() => _minRating = value);
      },
      selectedColor: const Color(0xFF6B28FD),
      backgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide.none,
    );
  }
}
