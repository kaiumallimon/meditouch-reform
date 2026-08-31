import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return OrdersRepository(apiClient);
});

class OrdersRepository {
  final ApiClient _apiClient;

  OrdersRepository(this._apiClient);

  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 50, String? status}) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty && status != 'ALL')
        'status': status,
    };

    final response = await _apiClient.get(
      ApiEndpoints.myOrders,
      queryParameters: queryParams,
    );

    if (response.data != null && response.data['data'] != null) {
      final items = response.data['data']['items'] as List<dynamic>? ?? [];
      return items.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<OrderModel> getOrderDetails(String orderId) async {
    final response = await _apiClient.get(ApiEndpoints.orderDetails(orderId));
    if (response.data != null && response.data['data'] != null) {
      return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Order not found');
  }

  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    final response = await _apiClient.post(
      ApiEndpoints.cancelOrder(orderId),
      data: {'reason': reason ?? 'Cancelled by user'},
    );

    if (response.data != null && response.data['data'] != null) {
      return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to cancel order');
  }
}
