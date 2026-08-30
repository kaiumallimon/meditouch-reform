import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_detail_model.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/providers/medicine_detail_provider.dart';

class MedicineDetailScreen extends ConsumerStatefulWidget {
  final String slug;
  final MedicineModel? initialMedicine;

  const MedicineDetailScreen({
    super.key,
    required this.slug,
    this.initialMedicine,
  });

  @override
  ConsumerState<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends ConsumerState<MedicineDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(medicineDetailProvider(widget.slug).notifier)
          .loadDetails(initialMedicine: widget.initialMedicine);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  void _handleShare(MedicineDetailModel? med) {
    final name = med?.medicineName ?? 'Medicine';
    final shareText = 'Check out $name on MediTouch: /pharmacy/medicine/${widget.slug}';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Link copied to clipboard',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(medicineDetailProvider(widget.slug));
    final notifier = ref.read(medicineDetailProvider(widget.slug).notifier);
    final med = state.medicine;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: IOS26AppBar(
        showBack: true,
        onBack: () => context.pop(),
        title: med?.medicineName ?? 'Medicine Details',
        actions: [
          IOS26AppBarAction(
            icon: LucideIcons.share2,
            tooltip: 'Share',
            onPressed: () => _handleShare(med),
          ),
          IOS26AppBarAction(
            icon: LucideIcons.shoppingBag,
            tooltip: 'Cart',
            onPressed: () => context.push(RouteNames.cart),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Scrollable Body
          if (state.isLoading && med == null)
            _buildLoadingSkeleton(isDark)
          else if (state.errorMessage != null && med == null)
            _buildErrorState(state.errorMessage!, notifier, isDark)
          else if (med != null)
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + 60,
                bottom: 120,
                left: 16,
                right: 16,
              ),
              children: [
                // 1. Hero Product Showcase Card
                _buildHeroCard(med, state, notifier, isDark),
                const SizedBox(height: 20),

                // 2. Clinical Monograph Sections
                if (med.sections.isNotEmpty) ...[
                  _buildMonographHeader(isDark),
                  const SizedBox(height: 12),
                  ...med.sections.map(
                    (sec) => _buildMonographCard(sec, isDark),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  _buildNoMonographCard(med, isDark),
                  const SizedBox(height: 20),
                ],

                // 4. Generic Alternatives (if available)
                if (med.relatedMedicines.isNotEmpty) ...[
                  _buildRelatedMedicinesSection(med.relatedMedicines, isDark),
                  const SizedBox(height: 20),
                ],
              ],
            ),

          // Bottom Floating Glass Action Bar
          if (med != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 12,
              child: _buildBottomActionBar(med, state, notifier, isDark),
            ),
        ],
      ),
    );
  }

  // 1. Hero Product Showcase Card
  Widget _buildHeroCard(
    MedicineDetailModel med,
    MedicineDetailState state,
    MedicineDetailNotifier notifier,
    bool isDark,
  ) {
    final activePack = state.activePack;
    final price = state.activePrice;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE5E5EA),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image Canvas with clean rounded inner island & badges
          Container(
            height: 220,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: med.image != null && med.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: med.image!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CupertinoActivityIndicator(
                                radius: 10,
                                color: isDark ? AppColors.primaryDark : AppColors.primary,
                              ),
                            ),
                            errorWidget: (_, __, ___) => _buildImageFallback(isDark),
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 150),
                          )
                        : _buildImageFallback(isDark),
                  ),
                ),

                // Category Badge (Top Left)
                Positioned(
                  top: 10,
                  left: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC084FC),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              (med.categoryName ?? med.dosageForm).toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Rx / OTC Badge (Top Right)
                Positioned(
                  top: 10,
                  right: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: med.rxRequired
                              ? const Color(0xFFDC2626).withValues(alpha: 0.90)
                              : const Color(0xFF059669).withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          med.rxRequired ? 'Rx Required' : 'OTC',
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Product Details & Specifications
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verified & Stock status badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0), width: 0.6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.shieldCheck, size: 11, color: Color(0xFF047857)),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: med.inStock ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: med.inStock ? const Color(0xFFBFDBFE) : const Color(0xFFFECACA),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            med.inStock ? LucideIcons.circleCheck : LucideIcons.circleAlert,
                            size: 11,
                            color: med.inStock ? const Color(0xFF1D4ED8) : const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            med.inStock ? 'In Stock' : 'Out of Stock',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: med.inStock ? const Color(0xFF1D4ED8) : const Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Medicine Name & Strength
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        med.medicineName,
                        style: GoogleFonts.youngSerif(
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.4,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (med.strength != null && med.strength!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        med.strength!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),

                // Generic Name
                if (med.genericName.isNotEmpty)
                  Text(
                    med.genericName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 6),

                // Manufacturer
                if (med.manufacturerName != null &&
                    med.manufacturerName!.trim().isNotEmpty &&
                    !RegExp(r'^\d+$').hasMatch(med.manufacturerName!.trim()))
                  Row(
                    children: [
                      Icon(
                        LucideIcons.building2,
                        size: 13,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Manufactured by: ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          med.manufacturerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                // Official Retail Price (MRP)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OFFICIAL RETAIL PRICE (MRP)',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatCurrency(price),
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activePack != null ? 'per ${activePack.unit}' : 'per ${med.packSize}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Available Pack Sizes Selector
                if (med.unitPrices.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'AVAILABLE PACK SIZES',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: med.unitPrices.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final pack = entry.value;
                      final isSelected = state.selectedPackIndex == idx;

                      return InkWell(
                        onTap: () => notifier.setSelectedPackIndex(idx),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.primaryDark.withValues(alpha: 0.20)
                                    : AppColors.primary.withValues(alpha: 0.08))
                                : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9FB)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : const Color(0xFFE5E5EA)),
                              width: isSelected ? 1.2 : 0.8,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    pack.unit,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected
                                          ? (isDark ? Colors.white : AppColors.primary)
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 4),
                                    Icon(
                                      LucideIcons.circleCheck,
                                      size: 11,
                                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatCurrency(pack.price),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 16),
                // 4-Column Quick Specification Tiles
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242426) : const Color(0xFFF6F6F8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildSpecTile('Form', med.dosageForm, isDark),
                      _buildSpecTile('Prescription', med.rxRequired ? 'Rx' : 'No (OTC)', isDark),
                      _buildSpecTile('Stock', med.inStock ? 'Available' : 'Out', isDark),
                      _buildSpecTile('Pack Units', activePack != null ? '${activePack.unitSize}' : '1', isDark),
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

  Widget _buildSpecTile(String label, String value, bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildMonographHeader(bool isDark) {
    return Row(
      children: [
        Icon(
          LucideIcons.bookOpen,
          size: 16,
          color: isDark ? AppColors.primaryDark : AppColors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Clinical Monograph & Details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // 3. Clinical Monograph Card (Supports standard text + FAQ Accordion)
  Widget _buildMonographCard(MonographSectionModel sec, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE5E5EA),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDark.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSectionIcon(sec.id),
                  size: 16,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              title: Text(
                sec.label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              subtitle: Text(
                sec.tag,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: sec.faqItems != null && sec.faqItems!.isNotEmpty
                      ? _buildFaqAccordionList(sec.faqItems!, isDark)
                      : Text(
                          sec.content,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.55,
                            color: isDark ? const Color(0xFFD1D1D6) : const Color(0xFF3C3C43),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FAQ Accordion Widget
  Widget _buildFaqAccordionList(List<FaqItemModel> items, bool isDark) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9FB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE5E5EA),
              width: 0.6,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Material(
              color: Colors.transparent,
              child: ExpansionTile(
                initiallyExpanded: idx == 0,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Q${idx + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  item.question,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.answer,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          height: 1.5,
                          color: isDark ? const Color(0xFFB0B0B5) : const Color(0xFF555558),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 4. Generic Alternatives (Consistent with Pharmacy Page Card)
  Widget _buildRelatedMedicinesSection(List<MedicineModel> related, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.layers,
              size: 16,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Generic Alternatives & Substitutes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 228,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, idx) {
              final alt = related[idx];
              return _buildAlternativeMedicineCard(alt, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeMedicineCard(MedicineModel alt, bool isDark) {
    return Container(
      width: 168,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push(
              '/pharmacy/medicine/${alt.slug ?? alt.id}',
              extra: alt,
            );
          },
          borderRadius: BorderRadius.circular(22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Image Canvas with clean rounded inner island & badges
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(6, 6, 6, 4),
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: alt.image != null && alt.image!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: alt.image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey.shade50,
                                    child: Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 8,
                                        color: isDark
                                            ? AppColors.primaryDark
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => _buildFallbackCardIcon(isDark),
                                  fadeInDuration: const Duration(milliseconds: 300),
                                  fadeOutDuration: const Duration(milliseconds: 150),
                                )
                              : _buildFallbackCardIcon(isDark),
                        ),
                      ),

                      // Category Capsule Pill (Top-Left)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.65)
                                    : Colors.white.withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : const Color(0xFFE5E5EA),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                alt.dosageForm.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Rx / OTC Badge (Top-Right)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 3),
                              decoration: BoxDecoration(
                                color: alt.rxRequired
                                    ? (isDark ? const Color(0xFF2C1518).withValues(alpha: 0.85) : const Color(0xFFFEF2F2))
                                    : (isDark ? const Color(0xFF13281C).withValues(alpha: 0.85) : const Color(0xFFECFDF5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: alt.rxRequired
                                      ? (isDark ? const Color(0xFF5C2025) : const Color(0xFFFECACA))
                                      : (isDark ? const Color(0xFF1E5032) : const Color(0xFFA7F3D0)),
                                  width: 0.6,
                                ),
                              ),
                              child: Text(
                                alt.rxRequired ? 'Rx' : 'OTC',
                                style: GoogleFonts.inter(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  color: alt.rxRequired
                                      ? (isDark ? const Color(0xFFFF6961) : const Color(0xFFDC2626))
                                      : (isDark ? const Color(0xFF30D158) : const Color(0xFF059669)),
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Compact Info Details
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product Name
                      Text(
                        alt.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Generic / Manufacturer / Brand
                      Builder(
                        builder: (context) {
                          final hasGeneric = alt.genericName != null && alt.genericName!.trim().isNotEmpty;
                          final hasMfg = alt.manufacturer.trim().isNotEmpty && !RegExp(r'^\d+$').hasMatch(alt.manufacturer.trim());
                          final hasBrand = alt.brand.trim().isNotEmpty && !RegExp(r'^\d+$').hasMatch(alt.brand.trim());

                          final subtitleText = hasGeneric
                              ? alt.genericName!.trim()
                              : (hasMfg
                                  ? alt.manufacturer.trim()
                                  : (hasBrand ? alt.brand.trim() : alt.dosageForm));

                          return Text(
                            subtitleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),

                      // Price & Liquid Glass View Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatCurrency(alt.unitPrice),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  alt.packSize,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 8.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Clean iOS 26 View / Navigate Button (No Gradient)
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : const Color(0xFFE5E5EA),
                                width: 0.8,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                LucideIcons.arrowRight,
                                size: 14,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackCardIcon(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
      child: Center(
        child: Icon(
          LucideIcons.pill,
          size: 26,
          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
        ),
      ),
    );
  }

  // 5. Floating Bottom Action Bar (iOS 26 Liquid Glass Dock)
  Widget _buildBottomActionBar(
    MedicineDetailModel med,
    MedicineDetailState state,
    MedicineDetailNotifier notifier,
    bool isDark,
  ) {
    final totalPrice = state.activePrice * state.quantity;

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF161618).withValues(alpha: 0.85)
                : const Color(0xFFF6F6F8).withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.90),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Liquid Glass Quantity Stepper Capsule
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFEAEAEE),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.70),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: state.quantity > 1 ? () => notifier.decrementQuantity() : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: state.quantity > 1 ? 0.12 : 0.04)
                              : Colors.white.withValues(alpha: state.quantity > 1 ? 0.90 : 0.40),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          LucideIcons.minus,
                          size: 13,
                          color: state.quantity > 1
                              ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                              : (isDark ? const Color(0xFF555558) : const Color(0xFFAAAAAE)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${state.quantity}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => notifier.incrementQuantity(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.14)
                              : Colors.white.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          LucideIcons.plus,
                          size: 13,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Gradient Add to Cart Liquid Pill Button
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${state.quantity}x ${med.medicineName} (${state.activeUnitLabel}) added to cart',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? const LinearGradient(
                                colors: [Color(0xFFA855F7), Color(0xFF9333EA), Color(0xFF7E22CE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF6B28FD), Color(0xFF5B15FC), Color(0xFF4C0FD9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.28),
                          width: 0.9,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? const Color(0xFF9333EA) : const Color(0xFF5B15FC))
                                .withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Frosted Icon Chip
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.shoppingBag,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Action Text & Price
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Add to Cart',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Text(
                                      '•',
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(totalPrice),
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildImageFallback(bool isDark) {
    return Center(
      child: Icon(
        LucideIcons.pill,
        size: 54,
        color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
      ),
    );
  }

  // Fallback card when clinical monograph is not yet indexed in database
  Widget _buildNoMonographCard(MedicineDetailModel med, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDark.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  LucideIcons.stethoscope,
                  size: 16,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Prescribing Summary',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'General pharmacological profile',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSummaryRow('Active Substance', med.genericName.isNotEmpty ? med.genericName : 'Not specified', isDark),
          _buildSummaryRow('Form & Strength', '${med.dosageForm}${med.strength != null && med.strength!.isNotEmpty ? " • ${med.strength}" : ""}', isDark),
          _buildSummaryRow('Therapeutic Category', med.categoryName ?? med.dosageForm, isDark),
          _buildSummaryRow('Prescription Status', med.rxRequired ? 'Prescription Required (Rx)' : 'Over The Counter (OTC)', isDark),
          if (med.manufacturerName != null &&
              med.manufacturerName!.trim().isNotEmpty &&
              !RegExp(r'^\d+$').hasMatch(med.manufacturerName!.trim()))
            _buildSummaryRow('Manufacturer', med.manufacturerName!, isDark),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF9F9FB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E5EA),
                width: 0.6,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 14,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Full monograph details are being indexed for ${med.medicineName}. Always take medications as directed by your physician.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      height: 1.4,
                      color: isDark ? const Color(0xFFB0B0B5) : const Color(0xFF555558),
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

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String id) {
    switch (id) {
      case 'indications':
        return LucideIcons.stethoscope;
      case 'dosage':
        return LucideIcons.clock;
      case 'pharmacology':
        return LucideIcons.flaskConical;
      case 'side_effects':
        return LucideIcons.triangleAlert;
      case 'precautions':
        return LucideIcons.shieldAlert;
      case 'contraindications':
        return LucideIcons.circleAlert;
      case 'pregnancy':
        return LucideIcons.baby;
      case 'interactions':
        return LucideIcons.heartPulse;
      case 'overdose':
        return LucideIcons.syringe;
      case 'therapeutic_class':
        return LucideIcons.layers;
      case 'description':
        return LucideIcons.info;
      case 'storage':
        return LucideIcons.archive;
      case 'faq':
        return LucideIcons.circleHelp;
      default:
        return LucideIcons.fileText;
    }
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return Center(
      child: CupertinoActivityIndicator(
        radius: 14,
        color: isDark ? AppColors.primaryDark : AppColors.primary,
      ),
    );
  }

  Widget _buildErrorState(
    String error,
    MedicineDetailNotifier notifier,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: 44,
              color: const Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              'Medicine Not Found',
              style: GoogleFonts.youngSerif(
                fontSize: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => notifier.loadDetails(),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
