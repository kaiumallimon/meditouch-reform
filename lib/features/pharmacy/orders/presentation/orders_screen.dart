import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meditouch/core/router/route_names.dart';
import 'package:meditouch/core/widgets/ios26_app_bar.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';
import 'package:meditouch/features/pharmacy/orders/presentation/providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(ordersListProvider);
    final selectedFilter = ref.watch(selectedOrderStatusFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: IOS26AppBar(
        title: 'Order History',
        showBack: true,
        actions: [
          IOS26AppBarAction(
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onPressed: () => ref.read(ordersListProvider.notifier).loadOrders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(ref, selectedFilter, isDark),

          // Orders List
          Expanded(
            child: ordersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text('Failed to load orders', style: theme.textTheme.titleMedium),
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
                  return _buildEmptyOrders(context, theme, isDark);
                }
                return RefreshIndicator(
                  onRefresh: () => ref.read(ordersListProvider.notifier).loadOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(context, ref, order, theme, isDark);
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
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final filter = filters[idx];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(
              filter,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFF5B15FC),
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val) {
                ref.read(selectedOrderStatusFilterProvider.notifier).state = filter;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context, ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Color(0xFF5B15FC),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Orders Placed Yet',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your past and active pharmacy orders will appear here for live status tracking.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(RouteNames.pharmacy),
              icon: const Icon(Icons.medication, size: 18),
              label: const Text('Browse Medicines'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B15FC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    ThemeData theme,
    bool isDark,
  ) {
    Color statusBg;
    Color statusText;
    Color statusBorder;

    switch (order.status) {
      case OrderStatusEnum.delivered:
        statusBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFDCFCE7);
        statusText = isDark ? const Color(0xFF34D399) : const Color(0xFF16A34A);
        statusBorder = isDark ? const Color(0xFF047857) : const Color(0xFF86EFAC);
        break;
      case OrderStatusEnum.shipped:
        statusBg = isDark ? const Color(0xFF3B0764) : const Color(0xFFF3E8FF);
        statusText = isDark ? const Color(0xFFC084FC) : const Color(0xFF9333EA);
        statusBorder = isDark ? const Color(0xFF6B21A8) : const Color(0xFFD8B4FE);
        break;
      case OrderStatusEnum.processing:
        statusBg = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
        statusText = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
        statusBorder = isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A);
        break;
      case OrderStatusEnum.cancelled:
        statusBg = isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
        statusText = isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
        statusBorder = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECACA);
        break;
      case OrderStatusEnum.confirmed:
        statusBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE);
        statusText = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
        statusBorder = isDark ? const Color(0xFF1D4ED8) : const Color(0xFF93C5FD);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
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
                    'Order #',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    order.createdAt.toLocal().toString().split('.')[0],
                    style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  order.status.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Items summary
          ...order.items.map(
            (it) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '•  (x)',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '৳',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
              const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(
                '৳',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF5B15FC),
                ),
              ),
            ],
          ),

          // Delivery Address
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ', ',
                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color),
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
                  onPressed: () => _showCancelDialog(context, ref, order),
                  icon: const Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                  label: const Text('Cancel Order', style: TextStyle(color: Colors.red, fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                )
              else if (order.status == OrderStatusEnum.shipped || order.status == OrderStatusEnum.delivered)
                Text(
                  order.status == OrderStatusEnum.shipped
                      ? 'In transit (Cannot cancel)'
                      : 'Delivered successfully',
                  style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color, fontStyle: FontStyle.italic),
                )
              else
                const SizedBox.shrink(),

              // View Details Sheet Button
              TextButton(
                onPressed: () => _showOrderDetailsSheet(context, order, theme, isDark),
                child: const Text('View Timeline', style: TextStyle(fontSize: 12, color: Color(0xFF5B15FC))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Order #?'),
        content: const Text(
          'Are you sure you want to cancel this order? All reserved medications will be restored back to pharmacy inventory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Order'),
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
                    SnackBar(content: Text('Failed to cancel: '), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Confirm Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showOrderDetailsSheet(BuildContext context, OrderModel order, ThemeData theme, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  'Order #',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text('Tracking Timeline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            if (order.trackingHistory.isNotEmpty)
              ...order.trackingHistory.map(
                (tr) => Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3.0),
                        child: Icon(Icons.radio_button_checked, size: 14, color: Color(0xFF5B15FC)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tr.status.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            if (tr.note.isNotEmpty)
                              Text(tr.note, style: TextStyle(fontSize: 11, color: theme.textTheme.bodySmall?.color)),
                          ],
                        ),
                      ),
                      Text(
                        tr.timestamp.toLocal().toString().split(' ')[1].substring(0, 5),
                        style: TextStyle(fontSize: 10, color: theme.textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Order confirmed. Preparation in progress.', style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color)),
              ),
          ],
        ),
      ),
    );
  }
}
