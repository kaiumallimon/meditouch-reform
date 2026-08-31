import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/pharmacy/cart/data/cart_repository.dart';
import 'package:meditouch/features/pharmacy/cart/domain/cart_item_model.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<CartSummaryModel>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartNotifier(repo);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cartState = ref.watch(cartProvider);
  return cartState.maybeWhen(
    data: (cart) => cart.itemsCount,
    orElse: () => 0,
  );
});

class CartNotifier extends StateNotifier<AsyncValue<CartSummaryModel>> {
  final CartRepository _repo;

  CartNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadCart();
  }

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    try {
      final cart = await _repo.getCart();
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(MedicineModel medicine, {int quantity = 1}) async {
    final medId = medicine.id.isNotEmpty ? medicine.id : (medicine.slug ?? 'med_${medicine.name.hashCode}');
    final currentCart = state.valueOrNull ?? const CartSummaryModel();
    final medImg = medicine.medicineImage ?? medicine.image;
    final existing = currentCart.items.firstWhere(
      (it) => it.medicineId == medId || (medicine.slug != null && it.medicineId == medicine.slug),
      orElse: () => CartItemModel(
        medicineId: medId,
        name: medicine.displayName,
        brand: medicine.brand,
        strength: medicine.strength ?? '',
        unitPrice: medicine.unitPrice,
        quantity: 0,
        totalPrice: 0,
        requiresPrescription: medicine.requiresPrescription,
        inStock: medicine.inStock,
        stockCount: medicine.stockCount,
        image: medImg,
      ),
    );

    final newQty = existing.quantity + quantity;
    final finalImg = (medImg != null && medImg.isNotEmpty) ? medImg : existing.image;

    await updateQuantity(
      existing.medicineId,
      newQty,
      seedItem: existing.copyWith(
        quantity: newQty,
        image: finalImg,
      ),
    );
  }

  Future<void> updateQuantity(String medicineId, int quantity, {CartItemModel? seedItem}) async {
    try {
      final updated = await _repo.updateItem(medicineId, quantity, seedItem: seedItem);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> increment(String medicineId) async {
    final cart = state.valueOrNull;
    if (cart == null) return;
    final item = cart.items.firstWhere(
      (it) => it.medicineId == medicineId,
      orElse: () => throw Exception('Item not in cart'),
    );
    if (item.quantity < item.stockCount) {
      await updateQuantity(medicineId, item.quantity + 1);
    }
  }

  Future<void> decrement(String medicineId) async {
    final cart = state.valueOrNull;
    if (cart == null) return;
    final item = cart.items.firstWhere(
      (it) => it.medicineId == medicineId,
      orElse: () => throw Exception('Item not in cart'),
    );
    if (item.quantity > 1) {
      await updateQuantity(medicineId, item.quantity - 1);
    } else {
      await removeItem(medicineId);
    }
  }

  Future<void> removeItem(String medicineId) async {
    try {
      final updated = await _repo.removeItem(medicineId);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearCart() async {
    try {
      final updated = await _repo.clearCart();
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
