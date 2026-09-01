import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/constants/app_colors.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';
import 'package:meditouch/features/pharmacy/orders/presentation/providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  String _formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
  }

  String _resolveImageUrl(String url) {
    var cleaned = url.trim();
    if (cleaned.isEmpty) return cleaned;
    if (defaultTargetPlatform == TargetPlatform.android) {
      cleaned = cleaned.replaceAll('http://localhost:8000', 'http://10.0.2.2:8000');
      cleaned = cleaned.replaceAll('http://127.0.0.1:8000', 'http://10.0.2.2:8000');
    }
    if (cleaned.startsWith('/')) {
      final host = ApiEndpoints.baseUrl.replaceAll('/api/v1', '');
      cleaned = '$host$cleaned';
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersListProvider);
    final selectedFilter = ref.watch(selectedOrderStatusFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Order History',
        showBack: true,
        onBack: () => context.pop(),
        actions: [
          IOS26AppBarAction(
            icon: LucideIcons.refreshCw,
            tooltip: 'Refresh Orders',
            onPressed: () => ref.read(ordersListProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: topInset + 54),
          // Capsule Filter Tabs
          _buildFilterTabs(ref, selectedFilter, isDark),

          // Orders Feed
          Expanded(
            child: ordersState.when(
              loading: () => Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              error: (err, _) => _buildErrorState(context, ref, err.toString(), isDark),
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyOrders(context, isDark, selectedFilter);
                }
                return RefreshIndicator(
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  onRefresh: () => ref.read(ordersListProvider.notifier).loadOrders(),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(context, ref, order, isDark);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // Horizontal Filter Tabs Bar
  // =========================================================================
  Widget _buildFilterTabs(WidgetRef ref, String selectedFilter, bool isDark) {
    const filters = [
      {'label': 'All Orders', 'value': 'ALL'},
      {'label': 'Confirmed', 'value': 'CONFIRMED'},
      {'label': 'Processing', 'value': 'PROCESSING'},
      {'label': 'Shipped', 'value': 'SHIPPED'},
      {'label': 'Delivered', 'value': 'DELIVERED'},
      {'label': 'Cancelled', 'value': 'CANCELLED'},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final filter = filters[idx];
          final isSelected = selectedFilter == filter['value'];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(selectedOrderStatusFilterProvider.notifier).state = filter['value']!;
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? (isDark
                          ? const LinearGradient(
                              colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                            ))
                      : null,
                  color: isSelected
                      ? null
                      : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : const Color(0xFFE5E5EA)),
                    width: 0.8,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (isDark ? const Color(0xFFA855F7) : const Color(0xFF5B15FC))
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    filter['label']!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================================
  // Status Metadata & Badge Helpers
  // =========================================================================
  Map<String, dynamic> _getStatusStyle(OrderStatusEnum status, bool isDark) {
    switch (status) {
      case OrderStatusEnum.delivered:
        return {
          'bg': isDark ? const Color(0xFF0F291E) : const Color(0xFFF0FDF4),
          'text': isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
          'border': isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0),
          'dot': const Color(0xFF10B981),
          'icon': LucideIcons.checkCircle2,
          'label': 'Delivered',
        };
      case OrderStatusEnum.shipped:
        return {
          'bg': isDark ? const Color(0xFF23143A) : const Color(0xFFF5F3FF),
          'text': isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7C3AED),
          'border': isDark ? const Color(0xFF5B21B6) : const Color(0xFFDDD6FE),
          'dot': const Color(0xFF8B5CF6),
          'icon': LucideIcons.truck,
          'label': 'Shipped',
        };
      case OrderStatusEnum.processing:
        return {
          'bg': isDark ? const Color(0xFF332009) : const Color(0xFFFFFBEB),
          'text': isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706),
          'border': isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          'dot': const Color(0xFFF59E0B),
          'icon': LucideIcons.package,
          'label': 'Processing',
        };
      case OrderStatusEnum.cancelled:
        return {
          'bg': isDark ? const Color(0xFF3B1214) : const Color(0xFFFEF2F2),
          'text': isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
          'border': isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
          'dot': const Color(0xFFEF4444),
          'icon': LucideIcons.xCircle,
          'label': 'Cancelled',
        };
      case OrderStatusEnum.confirmed:
        return {
          'bg': isDark ? const Color(0xFF132238) : const Color(0xFFEFF6FF),
          'text': isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB),
          'border': isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
          'dot': const Color(0xFF3B82F6),
          'icon': LucideIcons.clock,
          'label': 'Confirmed',
        };
    }
  }

  // =========================================================================
  // Redesigned Modern Order Card
  // =========================================================================
  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
    bool isDark,
  ) {
    final statusStyle = _getStatusStyle(order.status, isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.09) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => _showOrderDetailsSheet(context, ref, order, isDark),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Order Number, Date & Status Capsule (No overflow)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Order Icon Badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          LucideIcons.shoppingBag,
                          size: 17,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Order Number & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.orderNumber}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 10.5,
                                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(order.createdAt),
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Pill with Glowing Dot
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusStyle['bg'] as Color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: statusStyle['border'] as Color,
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: statusStyle['dot'] as Color,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusStyle['label'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: statusStyle['text'] as Color,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Hairline Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    thickness: 0.7,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE5E5EA),
                  ),
                ),

                // 2. Visual Products Preview Rows
                ...order.items.take(2).map(
                      (it) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image Thumbnail / Fallback
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : const Color(0xFFE5E5EA),
                                  width: 0.6,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: it.image != null && it.image!.trim().isNotEmpty
                                    ? Image.network(
                                        _resolveImageUrl(it.image!),
                                        fit: BoxFit.cover,
                                        width: 38,
                                        height: 38,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Icon(
                                            LucideIcons.pill,
                                            size: 16,
                                            color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Icon(
                                          LucideIcons.pill,
                                          size: 16,
                                          color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Name & Qty
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (it.strength.isNotEmpty) ...[
                                        Text(
                                          it.strength,
                                          style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                          ),
                                        ),
                                        Text(
                                          ' • ',
                                          style: GoogleFonts.inter(
                                            fontSize: 10.5,
                                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                          ),
                                        ),
                                      ],
                                      Text(
                                        'Qty: ${it.quantity}',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Item Total
                            Text(
                              _formatCurrency(it.totalPrice),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                // If more than 2 items, show expandable counter
                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+ ${order.items.length - 2} more item(s)',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                // 3. Delivery Address Box
                Container(
                  margin: const EdgeInsets.only(top: 4, bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : const Color(0xFFF9F9FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFEBEBF0),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.mapPin,
                        size: 12.5,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${order.deliveryAddress.streetAddress}, ${order.deliveryAddress.upazilaOrThana.isNotEmpty ? '${order.deliveryAddress.upazilaOrThana}, ' : ''}${order.deliveryAddress.district}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Total Amount & Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Total Payable Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Payable',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          _formatCurrency(order.totalAmount),
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    // Actions
                    Row(
                      children: [
                        if (order.canBeCancelled) ...[
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showCancelDialog(context, ref, order, isDark),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF3B1214)
                                      : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF7F1D1D)
                                        : const Color(0xFFFECACA),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.xCircle,
                                      size: 12.5,
                                      color: Color(0xFFEF4444),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cancel',
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFEF4444),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],

                        // View Timeline Action Pill
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showOrderDetailsSheet(context, ref, order, isDark),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: isDark
                                    ? const LinearGradient(
                                        colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                                      )
                                    : const LinearGradient(
                                        colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                                      ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Track Order',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    LucideIcons.arrowRight,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // Empty State & Error States
  // =========================================================================
  Widget _buildEmptyOrders(BuildContext context, bool isDark, String filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
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
              child: Center(
                child: Icon(
                  LucideIcons.receipt,
                  size: 36,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              filter == 'ALL' ? 'No Orders Placed Yet' : 'No $filter Orders',
              style: GoogleFonts.youngSerif(
                fontSize: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              filter == 'ALL'
                  ? 'Your active and past pharmacy orders will appear here with live tracking updates.'
                  : 'You currently have no orders in the $filter status category.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go(RouteNames.pharmacy),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                          ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? const Color(0xFFA855F7) : const Color(0xFF5B15FC))
                            .withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.pill, size: 15, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Browse Medicines',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.circleAlert, size: 42, color: Color(0xFFFF453A)),
            const SizedBox(height: 14),
            Text(
              'Unable to Load Orders',
              style: GoogleFonts.youngSerif(
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => ref.read(ordersListProvider.notifier).loadOrders(),
              icon: const Icon(LucideIcons.refreshCw, size: 14),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Interactive Order Details & Timeline Bottom Sheet
  // =========================================================================
  void _showOrderDetailsSheet(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
    bool isDark,
  ) {
    final statusStyle = _getStatusStyle(order.status, isDark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
          children: [
            // Drag Handle Pill
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row: Order Number, Copy Action, Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Order #${order.orderNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: order.orderNumber));
                                HapticFeedback.mediumImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order number copied to clipboard'),
                                    duration: Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  LucideIcons.copy,
                                  size: 14,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(order.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Banner Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: statusStyle['bg'] as Color,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: statusStyle['border'] as Color,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (statusStyle['text'] as Color).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        statusStyle['icon'] as IconData,
                        size: 18,
                        color: statusStyle['text'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusStyle['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: statusStyle['text'] as Color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getStatusDescription(order.status),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: (statusStyle['text'] as Color).withValues(alpha: 0.85),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Step-by-Step Delivery Stepper
            Text(
              'Delivery Tracking Steps',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTrackingStepper(order, isDark),
            const SizedBox(height: 20),

            // Items Breakdown Section
            Text(
              'Items in Order (${order.items.length})',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E5EA),
                  width: 0.8,
                ),
              ),
              child: Column(
                children: [
                  ...order.items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFE5E5EA),
                                width: 0.6,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: it.image != null && it.image!.trim().isNotEmpty
                                  ? Image.network(
                                      _resolveImageUrl(it.image!),
                                      fit: BoxFit.cover,
                                      width: 38,
                                      height: 38,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Icon(
                                          LucideIcons.pill,
                                          size: 16,
                                          color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        LucideIcons.pill,
                                        size: 16,
                                        color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_formatCurrency(it.unitPrice)} × ${it.quantity}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(it.totalPrice),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Line Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      thickness: 0.7,
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA),
                    ),
                  ),

                  // Subtotal & Flat Delivery Row
                  _buildPriceRow('Items Subtotal', _formatCurrency(order.subtotal), isDark, false),
                  const SizedBox(height: 5),
                  _buildPriceRow('Standard Express Delivery', _formatCurrency(order.deliveryFee), isDark, false),
                  const SizedBox(height: 8),
                  _buildPriceRow('Total Payable', _formatCurrency(order.totalAmount), isDark, true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Address Card
            Text(
              'Delivery Address',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E5EA),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE5E5EA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.deliveryAddress.label.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order.deliveryAddress.recipientName,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.deliveryAddress.recipientPhone,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.deliveryAddress.streetAddress}, ${order.deliveryAddress.upazilaOrThana.isNotEmpty ? '${order.deliveryAddress.upazilaOrThana}, ' : ''}${order.deliveryAddress.district}',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  if (order.customerNotes != null && order.customerNotes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.fileText,
                            size: 12,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Notes: ${order.customerNotes!.trim()}',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bottom Cancel Button inside Details if eligible
            if (order.canBeCancelled)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showCancelDialog(context, ref, order, isDark);
                  },
                  icon: const Icon(LucideIcons.xCircle, size: 15, color: Color(0xFFEF4444)),
                  label: Text(
                    'Cancel This Order',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Visual Stepper Implementation
  // =========================================================================
  Widget _buildTrackingStepper(OrderModel order, bool isDark) {
    if (order.status == OrderStatusEnum.cancelled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B1214) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.xCircle, size: 16, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'This order was cancelled. Reserved medications have been returned to inventory.',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final steps = [
      {'title': 'Order Confirmed', 'subtitle': 'Medications reserved from pharmacy'},
      {'title': 'Processing', 'subtitle': 'Packaging & verification by pharmacist'},
      {'title': 'Shipped', 'subtitle': 'Out for delivery across Dhaka'},
      {'title': 'Delivered', 'subtitle': 'Package delivered to recipient'},
    ];

    int currentStepIndex = 0;
    switch (order.status) {
      case OrderStatusEnum.confirmed:
        currentStepIndex = 0;
        break;
      case OrderStatusEnum.processing:
        currentStepIndex = 1;
        break;
      case OrderStatusEnum.shipped:
        currentStepIndex = 2;
        break;
      case OrderStatusEnum.delivered:
        currentStepIndex = 3;
        break;
      case OrderStatusEnum.cancelled:
        currentStepIndex = -1;
        break;
    }

    return Column(
      children: List.generate(steps.length, (index) {
        final isDone = index <= currentStepIndex;
        final isCurrent = index == currentStepIndex;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? (isDark ? AppColors.primaryDark : AppColors.primary)
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA)),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                        : Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF48484A) : const Color(0xFFAEAEB2),
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 28,
                    color: isDone && index < currentStepIndex
                        ? (isDark ? AppColors.primaryDark : AppColors.primary)
                        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA)),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0, bottom: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[index]['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.w800 : (isDone ? FontWeight.w600 : FontWeight.w500),
                        color: isDone
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                            : (isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93)),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      steps[index]['subtitle']!,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isDark, bool isTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 12.5 : 11.5,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal
                ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                : (isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93)),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 14 : 11.5,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal
                ? (isDark ? AppColors.primaryDark : AppColors.primary)
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  String _getStatusDescription(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.confirmed:
        return 'Order verified and registered in our pharmacy system.';
      case OrderStatusEnum.processing:
        return 'Medications being securely packed and inspected by a pharmacist.';
      case OrderStatusEnum.shipped:
        return 'Package is on the way with our express courier.';
      case OrderStatusEnum.delivered:
        return 'Order successfully delivered to your doorstep.';
      case OrderStatusEnum.cancelled:
        return 'Order cancelled. Inventory reserved has been restored.';
    }
  }

  // =========================================================================
  // Cancel Order Modal Dialog
  // =========================================================================
  void _showCancelDialog(BuildContext context, WidgetRef ref, OrderModel order, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(LucideIcons.triangleAlert, size: 20, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'Cancel Order?',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel Order #${order.orderNumber}? All reserved medications will be returned back to pharmacy stock.',
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep Order',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(ordersListProvider.notifier).cancelOrder(order.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order cancelled and inventory restored successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Confirm Cancel',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
