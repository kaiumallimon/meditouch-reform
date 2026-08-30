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

    // Ensure selected category exists in the list for dropdown
    final selectedCategoryValue = state.categories
            .any((c) => c.toUpperCase() == state.selectedCategory.toUpperCase())
        ? state.categories.firstWhere(
            (c) => c.toUpperCase() == state.selectedCategory.toUpperCase())
        : (state.categories.isNotEmpty ? state.categories.first : 'ALL');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'MediTouch Pharmacy',
          style: GoogleFonts.youngSerif(
            fontSize: 18,
            color: AppColors.textPrimary,
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
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => notifier.onSearchChanged(val),
                    style: GoogleFonts.inter(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search medicines, generics, brands...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 19),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 17),
                              onPressed: () {
                                _searchController.clear();
                                notifier.onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
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
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategoryValue,
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              isExpanded: true,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              items: state.categories.map((cat) {
                                final isAll = cat.toUpperCase() == 'ALL';
                                return DropdownMenuItem<String>(
                                  value: cat,
                                  child: Text(
                                    isAll ? 'All Categories' : cat,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: cat.toUpperCase() ==
                                              state.selectedCategory.toUpperCase()
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: cat.toUpperCase() ==
                                              state.selectedCategory.toUpperCase()
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
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
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.sortBy,
                            icon: const Icon(
                              Icons.sort_rounded,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
                  ? _buildLoadingGrid()
                  : state.errorMessage != null && state.medicines.isEmpty
                      ? _buildErrorView(state.errorMessage!, notifier)
                      : state.medicines.isEmpty
                          ? _buildEmptyView()
                          : RefreshIndicator(
                              onRefresh: () => notifier.loadMedicines(),
                              child: ListView(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(10),
                                children: [
                                  // Stats & Pagination Summary Header
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Showing ${((state.currentPage - 1) * state.limit) + 1}-${((state.currentPage - 1) * state.limit) + state.medicines.length} of ${state.totalItems} medicines',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          'Page ${state.currentPage} of ${state.totalPages}',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // 2 Medicines Per Row Grid (Ultra-compact, tight spacing)
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
                                      return _MedicineCard(medicine: medicine);
                                    },
                                  ),
                                  const SizedBox(height: 10),

                                  // Redesigned Sleek Pagination Bar
                                  _buildPaginationBar(state, notifier),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar(PharmacyState state, PharmacyNotifier notifier) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

    final pages = _getPaginationRange(state.currentPage, state.totalPages);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAE8E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          InkWell(
            onTap: state.currentPage > 1
                ? () {
                    notifier.prevPage();
                    _scrollToTop();
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: state.currentPage > 1 ? Colors.white : const Color(0xFFF9F9F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.currentPage > 1
                      ? AppColors.border
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 15,
                    color: state.currentPage > 1
                        ? AppColors.textPrimary
                        : AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  Text(
                    'Prev',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: state.currentPage > 1
                          ? AppColors.textPrimary
                          : AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Numbered Page Buttons
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: pages.map((p) {
                  if (p is String) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Text(
                        '...',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }

                  final pageNum = p as int;
                  final isCurrent = pageNum == state.currentPage;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        notifier.goToPage(pageNum);
                        _scrollToTop();
                      },
                      borderRadius: BorderRadius.circular(7),
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: isCurrent ? AppColors.primary : AppColors.border,
                          ),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          '$pageNum',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            color: isCurrent ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Next Button
          InkWell(
            onTap: state.currentPage < state.totalPages
                ? () {
                    notifier.nextPage();
                    _scrollToTop();
                  }
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: state.currentPage < state.totalPages
                    ? Colors.white
                    : const Color(0xFFF9F9F8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.currentPage < state.totalPages
                      ? AppColors.border
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Next',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: state.currentPage < state.totalPages
                          ? AppColors.textPrimary
                          : AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 15,
                    color: state.currentPage < state.totalPages
                        ? AppColors.textPrimary
                        : AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: const Center(
            child: CupertinoActivityIndicator(radius: 10, color: AppColors.primary),
          ),
        );
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 10),
            Text(
              'No Medicines Found',
              style: GoogleFonts.youngSerif(fontSize: 17, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with a different keyword or change active category.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, PharmacyNotifier notifier) {
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
              style: GoogleFonts.youngSerif(fontSize: 17, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textMuted),
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

  const _MedicineCard({required this.medicine});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAE8E4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F8),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    child: medicine.image != null && medicine.image!.isNotEmpty
                        ? Image.network(
                            medicine.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildFallbackIcon(),
                          )
                        : _buildFallbackIcon(),
                  ),
                ),

                // Category Pill (Top-Left)
                Positioned(
                  top: 5,
                  left: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          medicine.dosageForm.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Rx / OTC Badge (Top-Right)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 2),
                    decoration: BoxDecoration(
                      color: medicine.rxRequired
                          ? const Color(0xFFFEF2F2)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: medicine.rxRequired
                            ? const Color(0xFFFECACA)
                            : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: Text(
                      medicine.rxRequired ? 'Rx' : 'OTC',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: medicine.rxRequired
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF059669),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Compact Info Canvas (Zero Artificial Blank Gap)
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
                    color: AppColors.textPrimary,
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
                    color: AppColors.textMuted,
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
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            medicine.packSize,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 8.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Compact Add to Cart Button
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
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                          size: 14,
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
    return const Center(
      child: Icon(
        Icons.medication_rounded,
        size: 32,
        color: Color(0xFFD6D3D1),
      ),
    );
  }
}
