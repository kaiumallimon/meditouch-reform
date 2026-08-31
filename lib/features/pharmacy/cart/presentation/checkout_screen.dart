import 'dart:ui';
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
import 'package:meditouch/features/pharmacy/cart/data/cart_repository.dart';
import 'package:meditouch/features/pharmacy/cart/domain/cart_item_model.dart';
import 'package:meditouch/features/pharmacy/cart/presentation/providers/cart_provider.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';
import 'package:meditouch/features/profile/domain/address_model.dart';
import 'package:meditouch/features/profile/presentation/providers/address_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  AddressModel? _selectedAddress;
  bool _isAddingNewAddress = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _thanaController = TextEditingController();
  final _districtController = TextEditingController(text: 'Dhaka');
  final _notesController = TextEditingController();
  String _addressLabel = 'Home';
  bool _saveAddressForFuture = true;

  bool _isPlacingOrder = false;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '৳ ${formatter.format(amount)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _thanaController.dispose();
    _districtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final addressesState = ref.watch(savedAddressesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF2F2F7),
      appBar: IOS26AppBar(
        title: 'Confirm Checkout',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: cartState.when(
        loading: () => Center(
          child: CupertinoActivityIndicator(
            radius: 14,
            color: isDark ? AppColors.primaryDark : AppColors.primary,
          ),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading checkout: \$err',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
          ),
        ),
        data: (cart) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.shoppingBag,
                    size: 40,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.youngSerif(
                      fontSize: 18,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.pharmacy),
                    child: const Text('Go to Pharmacy'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.fromLTRB(14, topInset + 64, 14, 130),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressSection(context, addressesState, isDark),
                const SizedBox(height: 14),
                _buildItemsReviewSection(cart, isDark),
                const SizedBox(height: 14),
                _buildPaymentMethodSection(isDark),
                const SizedBox(height: 14),
                _buildNotesSection(isDark),
                const SizedBox(height: 14),
                _buildBillSummary(cart, isDark),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: cartState.maybeWhen(
        data: (cart) => cart.items.isNotEmpty
            ? _buildConfirmOrderBottomBar(context, cart, isDark)
            : const SizedBox.shrink(),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAddressSection(
    BuildContext context,
    AsyncValue<List<AddressModel>> addressesState,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 17,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Delivery Address',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (!_isAddingNewAddress)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isAddingNewAddress = true;
                    });
                  },
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: Text(
                    'New Address',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isAddingNewAddress) ...[
            _buildNewAddressForm(isDark),
          ] else ...[
            addressesState.when(
              loading: () => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoActivityIndicator(
                    radius: 10,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ),
              error: (_, __) => _buildNewAddressForm(isDark),
              data: (addresses) {
                if (addresses.isEmpty) {
                  return _buildNewAddressForm(isDark);
                }

                _selectedAddress ??= addresses.firstWhere(
                  (a) => a.isDefault,
                  orElse: () => addresses.first,
                );

                return Column(
                  children: addresses.map((addr) {
                    final isSelected = _selectedAddress?.id == addr.id ||
                        (_selectedAddress?.streetAddress == addr.streetAddress &&
                            _selectedAddress?.recipientName == addr.recipientName);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAddress = addr;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? AppColors.primaryDark.withValues(alpha: 0.12)
                                  : AppColors.primary.withValues(alpha: 0.06))
                              : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : const Color(0xFFE5E5EA)),
                            width: isSelected ? 1.5 : 0.8,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              margin: const EdgeInsets.only(top: 2, right: 10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                                      : (isDark ? const Color(0xFF636366) : const Color(0xFFA8A29E)),
                                  width: isSelected ? 5.5 : 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr.recipientName,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isDark
                                                ? Colors.white.withValues(alpha: 0.12)
                                                : const Color(0xFFE5E5EA),
                                          ),
                                        ),
                                        child: Text(
                                          addr.label,
                                          style: GoogleFonts.inter(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    addr.recipientPhone,
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '\${addr.streetAddress}, \${addr.upazilaOrThana}, \${addr.district}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewAddressForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Delivery Details',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              if (_isAddingNewAddress)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isAddingNewAddress = false;
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? AppColors.primaryDark : AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: ['Home', 'Office', 'Other'].map((lbl) {
              final isSel = _addressLabel == lbl;
              return GestureDetector(
                onTap: () => setState(() => _addressLabel = lbl),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel
                        ? (isDark ? AppColors.primaryDark : AppColors.primary)
                        : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel
                          ? (isDark ? AppColors.primaryDark : AppColors.primary)
                          : (isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA)),
                    ),
                  ),
                  child: Text(
                    lbl,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSel
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _nameController,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Recipient Full Name *',
              hintText: 'e.g. Tanvir Ahmed',
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter recipient name' : null,
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'Recipient Mobile Number *',
              hintText: '017XXXXXXXX',
              prefixText: '+88 ',
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
              if (v.trim().length < 10) return 'Please enter a valid phone number';
              return null;
            },
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _streetController,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              labelText: 'House, Road, Block / Street Address *',
              hintText: 'e.g. House 14, Road 5, Block C, Banani',
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter full street address' : null,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _thanaController,
                  style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Area / Thana *',
                    hintText: 'e.g. Dhanmondi',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _districtController,
                  style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'District / City *',
                    hintText: 'Dhaka',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          CheckboxListTile(
            value: _saveAddressForFuture,
            activeColor: isDark ? AppColors.primaryDark : AppColors.primary,
            onChanged: (val) => setState(() => _saveAddressForFuture = val ?? true),
            title: Text(
              'Save this address to profile for future orders',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsReviewSection(CartSummaryModel cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                LucideIcons.shoppingBag,
                size: 16,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Order Summary (\${cart.items.length} items)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...cart.items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\${it.name} (x\${it.quantity})',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (it.strength.isNotEmpty)
                          Text(
                            it.strength,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextMuted : const Color(0xFF8E8E93),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatCurrency(it.totalPrice),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(LucideIcons.shieldCheck, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 8),
              Text(
                'Payment & Confirmation',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F291E).withValues(alpha: 0.85)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.checkCircle2, color: Color(0xFF16A34A), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct Order Confirmation',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                          color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Instant order dispatch confirmation. Cash on Delivery or digital payment at door.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF166534),
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

  Widget _buildNotesSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                LucideIcons.fileText,
                size: 16,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Delivery Notes (Optional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            style: GoogleFonts.inter(fontSize: 13, color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: 'e.g. Call before arrival, leave at reception',
              filled: true,
              fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary(CartSummaryModel cart, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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

          _buildSummaryRow('Subtotal', _formatCurrency(cart.subtotal), isDark),
          const SizedBox(height: 8),
          _buildSummaryRow('Standard Delivery Fee', _formatCurrency(cart.deliveryFee), isDark),

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
                'Grand Total',
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

  Widget _buildConfirmOrderBottomBar(
    BuildContext context,
    CartSummaryModel cart,
    bool isDark,
  ) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding + 10),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF161618).withValues(alpha: 0.88)
            : const Color(0xFFF6F6F8).withValues(alpha: 0.92),
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SizedBox(
            height: 48,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isPlacingOrder ? null : () => _handlePlaceOrder(cart),
                borderRadius: BorderRadius.circular(24),
                child: Container(
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
                  child: Center(
                    child: _isPlacingOrder
                        ? const CupertinoActivityIndicator(radius: 10, color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Place Order & Confirm',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(CartSummaryModel cart) async {
    AddressModel deliveryAddress;

    if (_isAddingNewAddress || _selectedAddress == null) {
      if (!(_formKey.currentState?.validate() ?? false)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete all required address fields')),
          );
        }
        return;
      }

      deliveryAddress = AddressModel(
        label: _addressLabel,
        recipientName: _nameController.text.trim(),
        recipientPhone: _phoneController.text.trim(),
        division: 'Dhaka',
        district: _districtController.text.trim(),
        upazilaOrThana: _thanaController.text.trim(),
        streetAddress: _streetController.text.trim(),
      );

      if (_saveAddressForFuture) {
        ref.read(savedAddressesProvider.notifier).addAddress(deliveryAddress);
      }
    } else {
      deliveryAddress = _selectedAddress!;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final order = await ref.read(cartRepositoryProvider).checkout(
            deliveryAddress: deliveryAddress,
            customerNotes: _notesController.text.trim(),
          );

      ref.read(cartProvider.notifier).loadCart();

      if (!mounted) return;
      _showOrderSuccessSheet(order);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: \${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  void _showOrderSuccessSheet(OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF0F291E) : const Color(0xFFDCFCE7),
              ),
              child: const Icon(
                LucideIcons.checkCircle2,
                size: 50,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Confirmed!',
              style: GoogleFonts.youngSerif(
                fontSize: 22,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Order #\${order.orderNumber}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.primaryDark : AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your medications have been reserved from our pharmacy inventory and dispatch preparation has begun.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  context.go(RouteNames.orders);
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 48,
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
                  child: Center(
                    child: Text(
                      'Track My Orders',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.go(RouteNames.pharmacy);
              },
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.inter(
                  fontSize: 13,
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
