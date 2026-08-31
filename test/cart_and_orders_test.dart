import 'package:flutter_test/flutter_test.dart';
import 'package:meditouch/features/pharmacy/cart/domain/cart_item_model.dart';
import 'package:meditouch/features/pharmacy/orders/domain/order_model.dart';
import 'package:meditouch/features/profile/domain/address_model.dart';

void main() {
  group('Cart & Orders Unit Tests', () {
    test('CartItemModel calculation and summary', () {
      final item1 = CartItemModel(
        medicineId: 'med-1',
        name: 'Napa Extra',
        brand: 'Beximco',
        strength: '500mg + 65mg',
        unitPrice: 2.50,
        quantity: 10,
        totalPrice: 25.0,
        requiresPrescription: false,
      );

      final item2 = CartItemModel(
        medicineId: 'med-2',
        name: 'Azithromycin',
        brand: 'Square',
        strength: '500mg',
        unitPrice: 35.0,
        quantity: 2,
        totalPrice: 70.0,
        requiresPrescription: true,
      );

      final summary = CartSummaryModel.fromItems([item1, item2], deliveryFee: 85.0);

      expect(summary.itemsCount, 12);
      expect(summary.subtotal, 95.0);
      expect(summary.deliveryFee, 85.0);
      expect(summary.estimatedTotal, 180.0);
      expect(summary.hasPrescriptionItems, isTrue);
    });

    test('AddressModel serialization and deserialization', () {
      final addr = AddressModel(
        id: 'addr-123',
        label: 'Home',
        recipientName: 'Tanvir Ahmed',
        recipientPhone: '01711223344',
        division: 'Dhaka',
        district: 'Dhaka',
        upazilaOrThana: 'Dhanmondi',
        streetAddress: 'House 12, Road 4/A',
        isDefault: true,
      );

      final json = addr.toJson();
      final fromJson = AddressModel.fromJson(json);

      expect(fromJson.id, 'addr-123');
      expect(fromJson.recipientName, 'Tanvir Ahmed');
      expect(fromJson.streetAddress, 'House 12, Road 4/A');
      expect(fromJson.isDefault, isTrue);
    });

    test('OrderModel status lifecycle and cancellation rules', () {
      expect(OrderStatusEnum.confirmed.canBeCancelled, isTrue);
      expect(OrderStatusEnum.processing.canBeCancelled, isTrue);
      expect(OrderStatusEnum.shipped.canBeCancelled, isFalse);
      expect(OrderStatusEnum.delivered.canBeCancelled, isFalse);
      expect(OrderStatusEnum.cancelled.canBeCancelled, isFalse);

      final orderJson = {
        'id': 'ord-999',
        'order_number': 'ORD-99999',
        'user_id': 'user-1',
        'user_name': 'Tanvir',
        'user_phone': '01711223344',
        'items': [
          {
            'medicine_id': 'med-1',
            'name': 'Napa Extra',
            'unit_price': 2.5,
            'quantity': 10,
            'total_price': 25.0,
          }
        ],
        'subtotal': 25.0,
        'delivery_fee': 60.0,
        'total_amount': 85.0,
        'delivery_address': {
          'recipient_name': 'Tanvir',
          'recipient_phone': '01711223344',
          'district': 'Dhaka',
          'upazila_or_thana': 'Dhanmondi',
          'street_address': 'House 12',
        },
        'status': 'CONFIRMED',
        'created_at': '2026-08-31T20:00:00Z',
      };

      final order = OrderModel.fromJson(orderJson);
      expect(order.orderNumber, 'ORD-99999');
      expect(order.status, OrderStatusEnum.confirmed);
      expect(order.canBeCancelled, isTrue);
      expect(order.items.length, 1);
      expect(order.totalAmount, 85.0);
    });
  });
}
