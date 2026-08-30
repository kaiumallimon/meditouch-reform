class MedicineModel {
  final String id;
  final String name;
  final String brand;
  final String? genericName;
  final String? strength;
  final String dosageForm;
  final String? category;
  final String? categoryName;
  final String manufacturer;
  final double unitPrice;
  final String packSize;
  final String? image;
  final bool rxRequired;
  final bool inStock;
  final String? slug;
  final String? description;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.brand,
    this.genericName,
    this.strength,
    this.dosageForm = 'Tablet',
    this.category,
    this.categoryName,
    this.manufacturer = 'Pharma',
    this.unitPrice = 0.0,
    this.packSize = '1 Unit',
    this.image,
    this.rxRequired = false,
    this.inStock = true,
    this.slug,
    this.description,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['medicine_name']?.toString() ??
        json['brand']?.toString() ??
        json['name']?.toString() ??
        'Medicine';

    final rawBrand = json['brand']?.toString() ??
        json['medicine_name']?.toString() ??
        json['name']?.toString() ??
        '';

    final rawPrice = json['unit_price'] ?? json['price'];
    final priceVal = rawPrice is num
        ? rawPrice.toDouble()
        : (rawPrice != null ? (double.tryParse(rawPrice.toString()) ?? 0.0) : 0.0);

    final isRx = json['rx_required'] == true ||
        json['requires_prescription'] == true ||
        json['rx_required']?.toString().toLowerCase() == 'true' ||
        json['requires_prescription']?.toString().toLowerCase() == 'true';

    final inStockVal = json['in_stock'] is bool
        ? json['in_stock'] as bool
        : (json['is_available'] is bool
            ? json['is_available'] as bool
            : (json['in_stock']?.toString().toLowerCase() != 'false'));

    return MedicineModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: rawName,
      brand: rawBrand,
      genericName: json['generic_name']?.toString(),
      strength: json['strength']?.toString(),
      dosageForm: json['dosage_form']?.toString() ??
          json['category_name']?.toString() ??
          'Tablet',
      category: json['category']?.toString(),
      categoryName: json['category_name']?.toString(),
      manufacturer: json['manufacturer_name']?.toString() ??
          json['manufacturer']?.toString() ??
          'Pharma',
      unitPrice: priceVal,
      packSize: json['pack_size']?.toString() ?? '1 Unit',
      image: json['medicine_image']?.toString() ?? json['image']?.toString(),
      rxRequired: isRx,
      inStock: inStockVal,
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class PaginatedMedicines {
  final List<MedicineModel> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const PaginatedMedicines({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedMedicines.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) => MedicineModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return PaginatedMedicines(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrev: json['has_prev'] as bool? ?? false,
    );
  }
}
