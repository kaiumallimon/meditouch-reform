import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';
import 'package:meditouch/features/pharmacy/medicines/presentation/providers/pharmacy_provider.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<dynamic> _getPaginationRange(int current, int total) {
    if (total <= 5) {
      return List.generate(total, (i) => i + 1);
    }
    if (current <= 3) {
      return [1, 2, 3, '...', total];
    }
    if (current >= total - 2) {
      return [1, '...', total - 2, total - 1, total];
    }
    return [1, '...', current, '...', total];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pharmacyProvider);
    final notifier = ref.read(pharmacyProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Pharmacy',
        actions: [
          IOS26AppBarAction(
            icon: LucideIcons.fileText,
            tooltip: 'Orders',
            onPressed: () => context.push(RouteNames.orders),
          ),
          IOS26AppBarAction(
            icon: LucideIcons.shoppingBag,
            tooltip: 'Cart',
            onPressed: () => context.push(RouteNames.cart),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.loadMedicines(),
        edgeOffset: topInset + 64,
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.fromLTRB(14, topInset + 72, 14, 100),
            children: [
              // 1. iOS 26 Liquid Glass Search Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2C2E).withValues(alpha: 0.60)
                          : Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.14)
                            : const Color(0xFFE5E5EA),
                        width: 0.8,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => notifier.onSearchChanged(val),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search medicines, generics, brands...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFF98989F) : const Color(0xFF8E8E93),
                        ),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 16,
                          color: isDark ? const Color(0xFF98989F) : const Color(0xFF8E8E93),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  LucideIcons.x,
                                  size: 14,
                                  color: isDark ? const Color(0xFF98989F) : const Color(0xFF8E8E93),
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  notifier.onSearchChanged('');
                                },
                              )
                            : null,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. iOS 26 Full-Width Category Pills Carousel
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: state.categories.map((cat) {
                    final isSelected =
                        cat.toUpperCase() == state.selectedCategory.toUpperCase();
                    final isAll = cat.toUpperCase() == 'ALL';

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          notifier.setCategory(cat);
                          _scrollToTop();
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : AppColors.primary.withValues(alpha: 0.10))
                                : (isDark
                                    ? const Color(0xFF2C2C2E).withValues(alpha: 0.50)
                                    : Colors.white.withValues(alpha: 0.85)),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? Colors.white.withValues(alpha: 0.35)
                                      : AppColors.primary)
                                  : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE5E5EA)),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                              ],
                              Text(
                                isAll ? 'All Items' : cat,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? Colors.white : AppColors.primary)
                                      : (isDark
                                          ? const Color(0xFF8E8E93)
                                          : const Color(0xFF636366)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Main Content: Loading, Error, Empty, or 2-per-row Grid
              if (state.isLoading && state.medicines.isEmpty)
                _buildLoadingGrid(isDark)
              else if (state.errorMessage != null && state.medicines.isEmpty)
                _buildErrorView(state.errorMessage!, notifier, isDark)
              else if (state.medicines.isEmpty)
                _buildEmptyView(isDark)
              else ...[
                // Stats & Liquid Glass Sort Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Showing ${((state.currentPage - 1) * state.limit) + 1}-${((state.currentPage - 1) * state.limit) + state.medicines.length} of ${state.totalItems} medicines',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Liquid Glass Sort Pill
                      Container(
                        height: 28,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2E).withValues(alpha: 0.60)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE5E5EA),
                            width: 0.75,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.sortBy,
                            icon: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(
                                LucideIcons.arrowUpDown,
                                size: 12,
                                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                              ),
                            ),
                            dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'name_asc', child: Text('A–Z')),
                              DropdownMenuItem(value: 'name_desc', child: Text('Z–A')),
                              DropdownMenuItem(value: 'price_asc', child: Text('Price: Low')),
                              DropdownMenuItem(value: 'price_desc', child: Text('Price: High')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                notifier.setSortBy(val);
                                _scrollToTop();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // 2 Medicines Per Row iOS 26 Grid
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = state.medicines[index];
                      return _IOS26MedicineCard(medicine: medicine, isDark: isDark);
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // iOS 26 Seamless Squircle Pagination Bar
                _buildPaginationBar(state, notifier, isDark),
              ],
            ],
          ),
        ),
    );
  }

  Widget _buildPaginationBar(
    PharmacyState state,
    PharmacyNotifier notifier,
    bool isDark,
  ) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

    final pages = _getPaginationRange(state.currentPage, state.totalPages);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          InkWell(
            onTap: state.currentPage > 1
                ? () {
                    notifier.prevPage();
                    _scrollToTop();
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.currentPage > 1
                      ? (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E5EA))
                      : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF2F2F7)),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.chevronLeft,
                  size: 15,
                  color: state.currentPage > 1
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDark
                          ? AppColors.darkTextMuted.withValues(alpha: 0.35)
                          : const Color(0xFFC7C7CC)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Numbered Page Buttons
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: pages.map((p) {
                  if (p is String) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Text(
                        '•••',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                          letterSpacing: 1.2,
                        ),
                      ),
                    );
                  }

                  final pageNum = p as int;
                  final isCurrent = pageNum == state.currentPage;
                  final activeBg = isDark ? AppColors.primaryDark : AppColors.primary;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: InkWell(
                      onTap: () {
                        notifier.goToPage(pageNum);
                        _scrollToTop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? activeBg
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? activeBg
                                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA)),
                            width: 0.8,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: activeBg.withValues(alpha: isDark ? 0.35 : 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '$pageNum',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                            color: isCurrent
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Next Button
          InkWell(
            onTap: state.currentPage < state.totalPages
                ? () {
                    notifier.nextPage();
                    _scrollToTop();
                  }
                : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.currentPage < state.totalPages
                      ? (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E5EA))
                      : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF2F2F7)),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  LucideIcons.chevronRight,
                  size: 15,
                  color: state.currentPage < state.totalPages
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDark
                          ? AppColors.darkTextMuted.withValues(alpha: 0.35)
                          : const Color(0xFFC7C7CC)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.76,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E5EA),
              width: 0.8,
            ),
          ),
          child: Center(
            child: CupertinoActivityIndicator(
              radius: 11,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.searchX,
            size: 44,
            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
          ),
          const SizedBox(height: 12),
          Text(
            'No Medicines Found',
            style: GoogleFonts.youngSerif(
              fontSize: 17,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try searching with a different keyword or change active category.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, PharmacyNotifier notifier, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.circleAlert, size: 40, color: Color(0xFFFF453A)),
          const SizedBox(height: 12),
          Text(
            'Unable to Load Medicines',
            style: GoogleFonts.youngSerif(
              fontSize: 17,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => notifier.loadMedicines(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _IOS26MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final bool isDark;

  const _IOS26MedicineCard({required this.medicine, required this.isDark});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: medicine.image != null && medicine.image!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: medicine.image!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade50,
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    radius: 8,
                                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => _buildFallbackIcon(),
                              fadeInDuration: const Duration(milliseconds: 300),
                              fadeOutDuration: const Duration(milliseconds: 150),
                            )
                          : _buildFallbackIcon(),
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
                            medicine.dosageForm.toUpperCase(),
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
                            color: medicine.rxRequired
                                ? (isDark ? const Color(0xFF2C1518).withValues(alpha: 0.85) : const Color(0xFFFEF2F2))
                                : (isDark ? const Color(0xFF13281C).withValues(alpha: 0.85) : const Color(0xFFECFDF5)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: medicine.rxRequired
                                  ? (isDark ? const Color(0xFF5C2025) : const Color(0xFFFECACA))
                                  : (isDark ? const Color(0xFF1E5032) : const Color(0xFFA7F3D0)),
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            medicine.rxRequired ? 'Rx' : 'OTC',
                            style: GoogleFonts.inter(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              color: medicine.rxRequired
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
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name
                  Text(
                    medicine.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Generic / Manufacturer
                  Text(
                    medicine.genericName ?? medicine.manufacturer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price & Liquid Glass Add To Cart Button Row
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
                              _formatCurrency(medicine.unitPrice),
                              style: GoogleFonts.inter(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              medicine.packSize,
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

                      // iOS 26 Liquid Glass Add to Cart Button
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${medicine.name} added to cart',
                                style: GoogleFonts.inter(fontSize: 11.5),
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.18)
                                  : const Color(0xFFE5E5EA),
                              width: 0.8,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.plus,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            size: 16,
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
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        LucideIcons.pill,
        size: 32,
        color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
      ),
    );
  }
}
