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
import 'package:meditouch/features/pharmacy/cart/domain/cart_item_model.dart';
import 'package:meditouch/features/pharmacy/cart/presentation/providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Pharmacy Cart',
        showBack: true,
        onBack: () => context.pop(),
        actions: [
          if (cartState.maybeWhen(data: (cart) => cart.items.isNotEmpty, orElse: () => false))
            IOS26AppBarAction(
              icon: LucideIcons.trash2,
              tooltip: 'Clear Cart',
              isDestructive: true,
              onPressed: () => _showClearCartDialog(context, ref, isDark),
            ),
        ],
      ),
      body: cartState.when(
        loading: () => Center(
          child: CupertinoActivityIndicator(
            radius: 14,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        error: (err, _) => _buildErrorState(context, ref, err.toString(), isDark),
        data: (cart) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(context, isDark);
          }
          return _buildCartContent(context, ref, cart, isDark, topInset);
        },
      ),
      bottomNavigationBar: cartState.maybeWhen(
        data: (cart) => cart.items.isNotEmpty
            ? _buildFloatingCheckoutDock(context, cart, isDark)
            : const SizedBox.shrink(),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  // 1. Clean Empty Cart State matching Pharmacy screen
  Widget _buildEmptyCart(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Frosted Icon Container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white,
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
              child: Center(
                child: Icon(
                  LucideIcons.shoppingBag,
                  size: 38,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Your Cart is Empty',
              style: GoogleFonts.youngSerif(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Browse our e-pharmacy to add verified medicines, healthcare essentials, and prescriptions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),

            // Liquid Gradient Explore Medicines Button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go(RouteNames.pharmacy),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.pill,
                        size: 15,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Explore Medicines',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
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

  // 2. Active Cart List with iOS 26 Styling
  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    CartSummaryModel cart,
    bool isDark,
    double topInset,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.fromLTRB(14, topInset + 64, 14, 120),
      children: [
        // Prescription Warning Card if needed
        if (cart.hasPrescriptionItems)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C1518).withValues(alpha: 0.85)
                  : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF5C2025) : const Color(0xFFFECACA),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.circleAlert,
                  size: 18,
                  color: isDark ? const Color(0xFFFF6961) : const Color(0xFFDC2626),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "One or more items require a valid doctor's prescription during checkout verification.",
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFFF6961) : const Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cart Items (${cart.itemsCount})',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                '${cart.items.length} product(s)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Cart Items List
        ...cart.items.map((item) => _buildCartItemCard(context, ref, item, isDark)),

        const SizedBox(height: 14),

        // Delivery Note Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFE5E5EA),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.primaryDark : AppColors.primary).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.truck,
                  size: 14,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Express Delivery within 12-48 hours across Dhaka. Standard flat rate ৳85 applied.',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Bill Breakdown Card
        _buildBillBreakdownCard(cart, isDark),
      ],
    );
  }

  // 3. Individual Item Card with Island Thumbnail & Liquid Glass Stepper
  Widget _buildCartItemCard(
    BuildContext context,
    WidgetRef ref,
    CartItemModel item,
    bool isDark,
  ) {
    return Dismissible(
      key: ValueKey(item.medicineId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(22),
        ),
        child: const Icon(LucideIcons.trash2, color: Colors.white, size: 22),
      ),
      onDismissed: (_) {
        ref.read(cartProvider.notifier).removeItem(item.medicineId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${item.name} removed from cart',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rounded Clean Image Island
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE5E5EA),
                  width: 0.6,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: item.image != null && item.image!.trim().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.image!.trim(),
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Center(
                          child: CupertinoActivityIndicator(
                            radius: 8,
                            color: isDark ? AppColors.primaryDark : AppColors.primary,
                          ),
                        ),
                        errorWidget: (_, __, ___) => _buildItemFallbackIcon(isDark),
                      )
                    : _buildItemFallbackIcon(isDark),
              ),
            ),
            const SizedBox(width: 12),

            // Item Information & Quantity Stepper
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Delete Button
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            if (item.strength.isNotEmpty)
                              Text(
                                item.strength,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                ),
                              ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(cartProvider.notifier).removeItem(item.medicineId),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            LucideIcons.x,
                            size: 16,
                            color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price & Stepper Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Unit Price
                      Text(
                        _formatCurrency(item.unitPrice),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),

                      // iOS 26 Liquid Glass Stepper
                      Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.12)
                                : const Color(0xFFE5E5EA),
                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => ref.read(cartProvider.notifier).decrement(item.medicineId),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  LucideIcons.minus,
                                  size: 12,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '${item.quantity}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => ref.read(cartProvider.notifier).increment(item.medicineId),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.10)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  LucideIcons.plus,
                                  size: 12,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
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

  // 4. Price Summary Card
  Widget _buildBillBreakdownCard(CartSummaryModel cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.receipt,
                size: 16,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Price Summary',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildSummaryRow('Items Subtotal', _formatCurrency(cart.subtotal), isDark),
          const SizedBox(height: 8),
          _buildSummaryRow('Delivery Fee', _formatCurrency(cart.deliveryFee), isDark),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E5EA),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: GoogleFonts.inter(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Text(
                _formatCurrency(cart.estimatedTotal),
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // 5. Clean Fixed Bottom Dock with Compact Checkout Button (No Shadow, No Circle)
  Widget _buildFloatingCheckoutDock(BuildContext context, CartSummaryModel cart, bool isDark) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding > 0 ? bottomPadding + 8 : 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Price
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL PAYABLE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatCurrency(cart.estimatedTotal),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // Compact Checkout Button (No Shadow, No Circle, Reduced Width)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(RouteNames.checkout),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF6B28FD), Color(0xFF5B15FC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Checkout',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      LucideIcons.arrowRight,
                      size: 15,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemFallbackIcon(bool isDark) {
    return Center(
      child: Icon(
        LucideIcons.pill,
        size: 26,
        color: isDark ? const Color(0xFF48484A) : const Color(0xFFD6D3D1),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.circleAlert, size: 40, color: Color(0xFFFF453A)),
            const SizedBox(height: 12),
            Text(
              'Unable to Load Cart',
              style: GoogleFonts.youngSerif(
                fontSize: 18,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => ref.read(cartProvider.notifier).loadCart(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Cart?',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearCart();
            },
            child: Text(
              'Clear All',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF453A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
