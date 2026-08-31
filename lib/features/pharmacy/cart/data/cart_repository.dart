import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/core/storage/secure_storage.dart';
import 'package:meditouch/features/pharmacy/cart/domain/cart_item_model.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';
import 'package:meditouch/features/profile/domain/address_model.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return CartRepository(apiClient, storage);
});

class CartRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  static const String _localCartKey = 'meditouch_local_cart_items';

  CartRepository(this._apiClient, this._storage);

  Future<List<CartItemModel>> _loadLocalItems() async {
    final str = await _storage.read(_localCartKey);
    if (str == null || str.isEmpty) return [];
    try {
      final list = jsonDecode(str) as List<dynamic>;
      return list.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalItems(List<CartItemModel> items) async {
    final raw = items.map((e) => e.toJson()).toList();
    await _storage.write(_localCartKey, jsonEncode(raw));
  }

  Future<CartSummaryModel> getCart() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cart);
      if (response.data != null && response.data['data'] != null) {
        final summary = CartSummaryModel.fromJson(response.data['data'] as Map<String, dynamic>);
        await _saveLocalItems(summary.items);
        return summary;
      }
    } catch (_) {
      // Fallback to local storage
    }
    final local = await _loadLocalItems();
    return CartSummaryModel.fromItems(local, deliveryFee: 85.0);
  }

  Future<CartSummaryModel> updateItem(String medicineId, int quantity, {CartItemModel? seedItem}) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.cartItems,
        data: {'medicine_id': medicineId, 'quantity': quantity},
      );
      if (response.data != null && response.data['data'] != null) {
        final summary = CartSummaryModel.fromJson(response.data['data'] as Map<String, dynamic>);
        await _saveLocalItems(summary.items);
        return summary;
      }
    } catch (_) {
      // Local fallback
    }

    final local = await _loadLocalItems();
    final idx = local.indexWhere((it) => it.medicineId == medicineId);
    List<CartItemModel> updated = List.from(local);

    if (quantity <= 0) {
      if (idx != -1) updated.removeAt(idx);
    } else {
      if (idx != -1) {
        final current = updated[idx];
        updated[idx] = current.copyWith(
          quantity: quantity,
          image: (seedItem?.image != null && seedItem!.image!.isNotEmpty)
              ? seedItem.image
              : current.image,
          name: seedItem?.name ?? current.name,
          brand: seedItem?.brand ?? current.brand,
          strength: seedItem?.strength ?? current.strength,
          unitPrice: (seedItem != null && seedItem.unitPrice > 0)
              ? seedItem.unitPrice
              : current.unitPrice,
        );
      } else if (seedItem != null) {
        updated.add(seedItem.copyWith(quantity: quantity));
      }
    }

    await _saveLocalItems(updated);
    return CartSummaryModel.fromItems(updated, deliveryFee: 85.0);
  }

  Future<CartSummaryModel> removeItem(String medicineId) async {
    try {
      await _apiClient.delete('/items/');
    } catch (_) {}

    final local = await _loadLocalItems();
    final updated = local.where((it) => it.medicineId != medicineId).toList();
    await _saveLocalItems(updated);
    return CartSummaryModel.fromItems(updated, deliveryFee: 85.0);
  }

  Future<CartSummaryModel> clearCart() async {
    try {
      await _apiClient.delete(ApiEndpoints.cart);
    } catch (_) {}
    await _saveLocalItems([]);
    return const CartSummaryModel(items: [], deliveryFee: 85.0, estimatedTotal: 0.0);
  }

  Future<OrderModel> checkout({
    required AddressModel deliveryAddress,
    String? customerNotes,
    List<String>? prescriptionUrls,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.checkout,
      data: {
        'delivery_address': deliveryAddress.toJson(),
        if (customerNotes != null && customerNotes.isNotEmpty)
          'customer_notes': customerNotes,
        if (prescriptionUrls != null)
          'prescription_urls': prescriptionUrls,
      },
    );

    if (response.data != null && response.data['data'] != null) {
      await _saveLocalItems([]);
      return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }

    throw Exception('Failed to process checkout');
  }
}
