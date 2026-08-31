class CartItemModel {
  final String medicineId;
  final String name;
  final String brand;
  final String strength;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final bool requiresPrescription;
  final bool inStock;
  final int stockCount;
  final String? image;

  const CartItemModel({
    required this.medicineId,
    required this.name,
    this.brand = '',
    this.strength = '',
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.requiresPrescription = false,
    this.inStock = true,
    this.stockCount = 100,
    this.image,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      medicineId: json['medicine_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['medicine_name'] as String? ?? 'Medicine',
      brand: json['brand'] as String? ?? '',
      strength: json['strength'] as String? ?? '',
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      totalPrice: (json['total_price'] as num?)?.toDouble() ??
          ((json['unit_price'] as num?)?.toDouble() ?? 0.0) * ((json['quantity'] as num?)?.toInt() ?? 1),
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      inStock: json['in_stock'] as bool? ?? true,
      stockCount: (json['stock_count'] as num?)?.toInt() ?? 100,
      image: json['image'] as String? ??
          json['medicine_image'] as String? ??
          (json['medicine_images'] is List && (json['medicine_images'] as List).isNotEmpty
              ? (json['medicine_images'] as List).first.toString()
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_id': medicineId,
      'name': name,
      'brand': brand,
      'strength': strength,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_price': totalPrice,
      'requires_prescription': requiresPrescription,
      'in_stock': inStock,
      'stock_count': stockCount,
      if (image != null) 'image': image,
    };
  }

  CartItemModel copyWith({
    String? medicineId,
    String? name,
    String? brand,
    String? strength,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    bool? requiresPrescription,
    bool? inStock,
    int? stockCount,
    String? image,
  }) {
    final newQty = quantity ?? this.quantity;
    final newPrice = unitPrice ?? this.unitPrice;
    return CartItemModel(
      medicineId: medicineId ?? this.medicineId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      strength: strength ?? this.strength,
      unitPrice: newPrice,
      quantity: newQty,
      totalPrice: totalPrice ?? (newPrice * newQty),
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      inStock: inStock ?? this.inStock,
      stockCount: stockCount ?? this.stockCount,
      image: image ?? this.image,
    );
  }
}

class CartSummaryModel {
  final List<CartItemModel> items;
  final int itemsCount;
  final double subtotal;
  final double deliveryFee;
  final double estimatedTotal;
  final bool hasPrescriptionItems;

  const CartSummaryModel({
    this.items = const [],
    this.itemsCount = 0,
    this.subtotal = 0.0,
    this.deliveryFee = 85.0,
    this.estimatedTotal = 85.0,
    this.hasPrescriptionItems = false,
  });

  factory CartSummaryModel.fromItems(List<CartItemModel> items, {double deliveryFee = 85.0}) {
    final sub = items.fold<double>(0.0, (sum, it) => sum + (it.unitPrice * it.quantity));
    final fee = items.isEmpty ? 0.0 : deliveryFee;
    final hasRx = items.any((it) => it.requiresPrescription);
    return CartSummaryModel(
      items: items,
      itemsCount: items.fold<int>(0, (sum, it) => sum + it.quantity),
      subtotal: sub,
      deliveryFee: fee,
      estimatedTotal: sub + fee,
      hasPrescriptionItems: hasRx,
    );
  }

  factory CartSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['items'] as List<dynamic>? ?? [];
    final items = rawList.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    final subtotalVal = (json['subtotal'] as num?)?.toDouble() ??
        items.fold<double>(0.0, (sum, it) => sum + (it.unitPrice * it.quantity));
    final feeVal = (json['delivery_fee'] as num?)?.toDouble() ?? 85.0;
    final totalVal = (json['estimated_total'] as num?)?.toDouble() ?? (subtotalVal + feeVal);

    return CartSummaryModel(
      items: items,
      itemsCount: (json['items_count'] as num?)?.toInt() ?? items.length,
      subtotal: subtotalVal,
      deliveryFee: feeVal,
      estimatedTotal: totalVal,
      hasPrescriptionItems: json['has_prescription_items'] as bool? ?? false,
    );
  }
}
