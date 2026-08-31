import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/features/pharmacy/orders/data/orders_repository.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';

final selectedOrderStatusFilterProvider = StateProvider<String>((ref) => 'ALL');

final ordersListProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  final repo = ref.watch(ordersRepositoryProvider);
  final filter = ref.watch(selectedOrderStatusFilterProvider);
  return OrdersNotifier(repo, filter);
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final OrdersRepository _repo;
  final String _filter;

  OrdersNotifier(this._repo, this._filter) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    try {
      final orders = await _repo.getMyOrders(
        status: _filter != 'ALL' ? _filter : null,
      );
      state = AsyncValue.data(orders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    try {
      final updated = await _repo.cancelOrder(orderId, reason: reason);
      final current = state.valueOrNull ?? [];
      state = AsyncValue.data(
        current.map((o) => o.id == orderId ? updated : o).toList(),
      );
      return updated;
    } catch (e) {
      rethrow;
    }
  }
}
