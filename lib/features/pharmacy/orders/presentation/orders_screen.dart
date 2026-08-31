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
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';
import 'package:meditouch/features/pharmacy/orders/presentation/providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
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
            tooltip: 'Refresh',
            onPressed: () => ref.read(ordersListProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: topInset + 54),
          // Filter Tabs
          _buildFilterTabs(ref, selectedFilter, isDark),

          // Orders List
          Expanded(
            child: ordersState.when(
              loading: () => Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.circleAlert, size: 40, color: Color(0xFFFF453A)),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to Load Orders',
                        style: GoogleFonts.youngSerif(
                          fontSize: 18,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.read(ordersListProvider.notifier).loadOrders(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (orders) {
                if (orders.isEmpty) {
                  return _buildEmptyOrders(context, isDark);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(ordersListProvider.notifier).loadOrders(),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(14, 6, 14, 40),
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

  Widget _buildFilterTabs(WidgetRef ref, String selectedFilter, bool isDark) {
    const filters = ['ALL', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'];

    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final filter = filters[idx];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => ref.read(selectedOrderStatusFilterProvider.notifier).state = filter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryDark : AppColors.primary)
                    : (isDark ? const Color(0xFF1C1C1E) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA)),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context, bool isDark) {
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
              'No Orders Placed Yet',
              style: GoogleFonts.youngSerif(
                fontSize: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your past and active pharmacy orders will appear here for live status tracking.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.4,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                          ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.pill, size: 14, color: Colors.white),
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

  Widget _buildOrderCard(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
    bool isDark,
  ) {
    Color statusBg;
    Color statusText;
    Color statusBorder;

    switch (order.status) {
      case OrderStatusEnum.delivered:
        statusBg = isDark ? const Color(0xFF0F291E) : const Color(0xFFDCFCE7);
        statusText = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
        statusBorder = isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC);
        break;
      case OrderStatusEnum.shipped:
        statusBg = isDark ? const Color(0xFF2C1338) : const Color(0xFFF3E8FF);
        statusText = isDark ? const Color(0xFFD8B4FE) : const Color(0xFF9333EA);
        statusBorder = isDark ? const Color(0xFF581C87) : const Color(0xFFD8B4FE);
        break;
      case OrderStatusEnum.processing:
        statusBg = isDark ? const Color(0xFF332009) : const Color(0xFFFEF3C7);
        statusText = isDark ? const Color(0xFFFCD34D) : const Color(0xFFD97706);
        statusBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
        break;
      case OrderStatusEnum.cancelled:
        statusBg = isDark ? const Color(0xFF3B1214) : const Color(0xFFFEE2E2);
        statusText = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626);
        statusBorder = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
        break;
      case OrderStatusEnum.confirmed:
        statusBg = isDark ? const Color(0xFF132238) : const Color(0xFFDBEAFE);
        statusText = isDark ? const Color(0xFF93C5FD) : const Color(0xFF2563EB);
        statusBorder = isDark ? const Color(0xFF1E40AF) : const Color(0xFF93C5FD);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Number & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    order.createdAt.toLocal().toString().split('.')[0],
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBorder, width: 0.8),
                ),
                child: Text(
                  order.status.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusText,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA),
            ),
          ),

          // Items summary
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '• ${it.name} (x${it.quantity})',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatCurrency(it.totalPrice),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                _formatCurrency(order.totalAmount),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ],
          ),

          // Delivery Address
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                LucideIcons.mapPin,
                size: 13,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${order.deliveryAddress.streetAddress}, ${order.deliveryAddress.district}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Cancel Order / Status actions
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (order.canBeCancelled)
                OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, ref, order, isDark),
                  icon: const Icon(LucideIcons.xCircle, size: 13, color: Color(0xFFFF453A)),
                  label: Text(
                    'Cancel Order',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFFF453A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF7F1D1D), width: 0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                )
              else if (order.status == OrderStatusEnum.shipped || order.status == OrderStatusEnum.delivered)
                Text(
                  order.status == OrderStatusEnum.shipped
                      ? 'In transit (Cannot cancel)'
                      : 'Delivered successfully',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else
                const SizedBox.shrink(),

              // View Details Sheet Button
              TextButton.icon(
                onPressed: () => _showOrderDetailsSheet(context, order, isDark),
                icon: const Icon(LucideIcons.history, size: 13),
                label: Text(
                  'View Timeline',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, OrderModel order, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Cancel Order #${order.orderNumber}?',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel this order? All reserved medications will be restored back to pharmacy inventory.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Order', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(ordersListProvider.notifier).cancelOrder(order.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order cancelled and stock restored successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: Text(
              'Confirm Cancel',
              style: GoogleFonts.inter(color: const Color(0xFFFF453A), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, OrderModel order, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Tracking Timeline',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (order.trackingHistory.isNotEmpty)
              ...order.trackingHistory.map(
                (tr) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Icon(
                          LucideIcons.checkCircle2,
                          size: 14,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr.status.displayName,
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            if (tr.note.isNotEmpty)
                              Text(
                                tr.note,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        tr.timestamp.toLocal().toString().split(' ')[1].substring(0, 5),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Order confirmed. Preparation in progress.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
