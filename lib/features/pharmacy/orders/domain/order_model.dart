import 'package:meditouch/features/pharmacy/cart/domain/cart_item_model.dart';
import 'package:meditouch/features/profile/domain/address_model.dart';

enum OrderStatusEnum {
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled;

  static OrderStatusEnum fromString(String status) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatusEnum.confirmed;
      case 'PROCESSING':
        return OrderStatusEnum.processing;
      case 'SHIPPED':
        return OrderStatusEnum.shipped;
      case 'DELIVERED':
        return OrderStatusEnum.delivered;
      case 'CANCELLED':
        return OrderStatusEnum.cancelled;
      default:
        return OrderStatusEnum.confirmed;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatusEnum.confirmed:
        return 'CONFIRMED';
      case OrderStatusEnum.processing:
        return 'PROCESSING';
      case OrderStatusEnum.shipped:
        return 'SHIPPED';
      case OrderStatusEnum.delivered:
        return 'DELIVERED';
      case OrderStatusEnum.cancelled:
        return 'CANCELLED';
    }
  }

  bool get canBeCancelled =>
      this == OrderStatusEnum.confirmed || this == OrderStatusEnum.processing;
}

class TrackingEventModel {
  final OrderStatusEnum status;
  final String note;
  final DateTime timestamp;

  const TrackingEventModel({
    required this.status,
    required this.note,
    required this.timestamp,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      status: OrderStatusEnum.fromString(json['status'] as String? ?? 'CONFIRMED'),
      note: json['note'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final String userName;
  final String userPhone;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final AddressModel deliveryAddress;
  final OrderStatusEnum status;
  final bool requiresPrescription;
  final List<String> prescriptionUrls;
  final String? customerNotes;
  final List<TrackingEventModel> trackingHistory;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    this.requiresPrescription = false,
    this.prescriptionUrls = const [],
    this.customerNotes,
    this.trackingHistory = const [],
    required this.createdAt,
  });

  bool get canBeCancelled => status.canBeCancelled;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final itemsList = rawItems
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawEvents = json['tracking_history'] as List<dynamic>? ?? [];
    final eventsList = rawEvents
        .map((e) => TrackingEventModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final addrJson = json['delivery_address'] as Map<String, dynamic>? ?? {};

    return OrderModel(
      id: json['id'] as String? ?? '',
      orderNumber: json['order_number'] as String? ?? json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
      userPhone: json['user_phone'] as String? ?? '',
      items: itemsList,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: AddressModel.fromJson(addrJson),
      status: OrderStatusEnum.fromString(json['status'] as String? ?? 'CONFIRMED'),
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      prescriptionUrls: (json['prescription_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      customerNotes: json['customer_notes'] as String?,
      trackingHistory: eventsList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
