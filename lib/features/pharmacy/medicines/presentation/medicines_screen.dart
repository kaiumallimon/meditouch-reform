import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
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

    // Ensure selected category exists in the list for dropdown
    final selectedCategoryValue = state.categories
            .any((c) => c.toUpperCase() == state.selectedCategory.toUpperCase())
        ? state.categories.firstWhere(
            (c) => c.toUpperCase() == state.selectedCategory.toUpperCase())
        : (state.categories.isNotEmpty ? state.categories.first : 'ALL');

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        title: Text(
          'MediTouch Pharmacy',
          style: GoogleFonts.youngSerif(
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Orders',
            onPressed: () => context.push(RouteNames.orders),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            tooltip: 'Cart',
            onPressed: () => context.push(RouteNames.cart),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Dropdown Filters
            Container(
              color: isDark ? AppColors.darkBackground : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  // Search Input
                  TextField(
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
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 19,
                        color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                size: 17,
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                notifier.onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurface : AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.border,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Category & Sort Dropdowns Row
                  Row(
                    children: [
                      // Category Dropdown
                      Expanded(
                        child: Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategoryValue,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                              ),
                              dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                              isExpanded: true,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                              items: state.categories.map((cat) {
                                final isAll = cat.toUpperCase() == 'ALL';
                                final isSelected =
                                    cat.toUpperCase() == state.selectedCategory.toUpperCase();

                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(
                                    isAll ? 'All Categories' : cat,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected
                                          ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                          : (isDark
                                              ? AppColors.darkTextPrimary
                                              : AppColors.textPrimary),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  notifier.setCategory(val);
                                  _scrollToTop();
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Sort By Dropdown
                      Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.sortBy,
                            icon: Icon(
                              Icons.sort_rounded,
                              size: 16,
                              color: isDark ? AppColors.darkTextMuted : AppColors.textSecondary,
                            ),
                            dropdownColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'name_asc',
                                child: Text('Name A-Z'),
                              ),
                              DropdownMenuItem(
                                value: 'name_desc',
                                child: Text('Name Z-A'),
                              ),
                              DropdownMenuItem(
                                value: 'price_asc',
                                child: Text('Price: Low'),
                              ),
                              DropdownMenuItem(
                                value: 'price_desc',
                                child: Text('Price: High'),
                              ),
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
                ],
              ),
            ),

            // Medicines Grid (2 per row) + Pagination
            Expanded(
              child: state.isLoading && state.medicines.isEmpty
                  ? _buildLoadingGrid(isDark)
                  : state.errorMessage != null && state.medicines.isEmpty
                      ? _buildErrorView(state.errorMessage!, notifier, isDark)
                      : state.medicines.isEmpty
                          ? _buildEmptyView(isDark)
                          : RefreshIndicator(
                              onRefresh: () => notifier.loadMedicines(),
                              child: ListView(
                                controller: _scrollController,
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                                children: [
                                  // Stats & Pagination Summary Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Showing ${((state.currentPage - 1) * state.limit) + 1}-${((state.currentPage - 1) * state.limit) + state.medicines.length} of ${state.totalItems} medicines',
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Page ${state.currentPage} of ${state.totalPages}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // 2 Medicines Per Row Grid
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.78,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: state.medicines.length,
                                    itemBuilder: (context, index) {
                                      final medicine = state.medicines[index];
                                      return _MedicineCard(medicine: medicine, isDark: isDark);
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Clean Seamless Pagination Bar
                                  _buildPaginationBar(state, notifier, isDark),
                                ],
                              ),
                            ),
            ),
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.currentPage > 1
                      ? (isDark ? AppColors.darkBorder : const Color(0xFFE7E5E4))
                      : (isDark ? AppColors.darkBorderSubtle : const Color(0xFFF0EEEB)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 13,
                  color: state.currentPage > 1
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDark
                          ? AppColors.darkTextMuted.withValues(alpha: 0.35)
                          : AppColors.textMuted.withValues(alpha: 0.35)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Numbered Page Buttons
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
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
                          color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? activeBg
                              : (isDark ? AppColors.darkSurface : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent
                                ? activeBg
                                : (isDark ? AppColors.darkBorder : const Color(0xFFE7E5E4)),
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: activeBg.withValues(alpha: 0.35),
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
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.currentPage < state.totalPages
                      ? (isDark ? AppColors.darkBorder : const Color(0xFFE7E5E4))
                      : (isDark ? AppColors.darkBorderSubtle : const Color(0xFFF0EEEB)),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: state.currentPage < state.totalPages
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDark
                          ? AppColors.darkTextMuted.withValues(alpha: 0.35)
                          : AppColors.textMuted.withValues(alpha: 0.35)),
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
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorderSubtle : AppColors.borderSubtle,
            ),
          ),
          child: Center(
            child: CupertinoActivityIndicator(
              radius: 10,
              color: isDark ? AppColors.primaryDark : AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 48,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            const SizedBox(height: 10),
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
      ),
    );
  }

  Widget _buildErrorView(String message, PharmacyNotifier notifier, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.error),
            const SizedBox(height: 10),
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
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineModel medicine;
  final bool isDark;

  const _MedicineCard({required this.medicine, required this.isDark});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.primaryDark : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFEAE8E4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Prominent Top Image
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141416) : const Color(0xFFF9F9F8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: medicine.image != null && medicine.image!.isNotEmpty
                        ? Image.network(
                            medicine.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                          )
                        : _buildFallbackIcon(),
                  ),
                ),

                // Fully Rounded Neutral Category Pill (Top-Left)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceElevated
                          : Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4.5,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: activeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3.5),
                        Text(
                          medicine.dosageForm.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Fully Rounded Rx / OTC Badge (Top-Right)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: medicine.rxRequired
                          ? (isDark ? const Color(0xFF2C1518) : const Color(0xFFFEF2F2))
                          : (isDark ? const Color(0xFF13281C) : const Color(0xFFECFDF5)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: medicine.rxRequired
                            ? (isDark ? const Color(0xFF5C2025) : const Color(0xFFFECACA))
                            : (isDark ? const Color(0xFF1E5032) : const Color(0xFFA7F3D0)),
                      ),
                    ),
                    child: Text(
                      medicine.rxRequired ? 'Rx' : 'OTC',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: medicine.rxRequired
                            ? (isDark ? const Color(0xFFFF6961) : const Color(0xFFDC2626))
                            : (isDark ? const Color(0xFF30D158) : const Color(0xFF059669)),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Compact Info Canvas
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1.5),

                // Generic / Manufacturer
                Text(
                  medicine.genericName ?? medicine.manufacturer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 5),

                // Price & Add To Cart Row
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
                              fontSize: 12.5,
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
                              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Rounded Add to Cart Button
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
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 15,
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
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        Icons.medication_rounded,
        size: 32,
        color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
      ),
    );
  }
}
