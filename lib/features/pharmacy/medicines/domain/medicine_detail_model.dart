import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';

double _parseDouble(dynamic val, [double defaultVal = 0.0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toDouble();
  if (val is String) {
    return double.tryParse(val.trim()) ?? defaultVal;
  }
  return defaultVal;
}

int _parseInt(dynamic val, [int defaultVal = 0]) {
  if (val == null) return defaultVal;
  if (val is num) return val.toInt();
  if (val is String) {
    return int.tryParse(val.trim()) ?? defaultVal;
  }
  return defaultVal;
}

String cleanMonographText(String rawContent) {
  if (rawContent.trim().isEmpty) return '';
  return rawContent
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<h[1-6][^>]*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'</h[1-6]>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '\n• ')
      .replaceAll(RegExp(r'</li>', caseSensitive: false), '')
      .replaceAll(RegExp(r'</?(?:ul|ol)[^>]*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</?table[^>]*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</?tr[^>]*>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</?t[dh][^>]*>', caseSensitive: false), '  ')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'&amp;', caseSensitive: false), '&')
      .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<')
      .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>')
      .replaceAll(RegExp(r'&quot;', caseSensitive: false), '"')
      .replaceAll(RegExp(r'&#39;', caseSensitive: false), "'")
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}

class UnitPriceModel {
  final dynamic id;
  final String unit;
  final int unitSize;
  final double price;

  const UnitPriceModel({
    this.id,
    required this.unit,
    required this.unitSize,
    required this.price,
  });

  factory UnitPriceModel.fromJson(Map<String, dynamic> json) {
    return UnitPriceModel(
      id: json['id'],
      unit: json['unit']?.toString() ?? 'Unit',
      unitSize: _parseInt(json['unit_size'], 1),
      price: _parseDouble(json['price'], 0.0),
    );
  }
}

class FaqItemModel {
  final String question;
  final String answer;

  const FaqItemModel({
    required this.question,
    required this.answer,
  });

  static List<FaqItemModel> parseFaqContent(String rawContent) {
    if (rawContent.trim().isEmpty) return [];

    final normalized = cleanMonographText(rawContent);

    final List<FaqItemModel> items = [];
    final chunks = normalized.split(
      RegExp(r'(?=(?:^|\n)\s*(?:Q\s*\d*[:\.\-]|Question\s*\d*[:\.\-]))', caseSensitive: false),
    );

    for (final chunk in chunks) {
      final trimmedChunk = chunk.trim();
      if (trimmedChunk.isEmpty) continue;

      final answerSplit = trimmedChunk.split(
        RegExp(r'(?:^|\n|\s{2,})(?:A\s*\d*[:\.\-]|Answer\s*\d*[:\.\-])\s*', caseSensitive: false),
      );
      if (answerSplit.length >= 2) {
        final qText = answerSplit[0]
            .replaceAll(RegExp(r'^(?:Q\s*\d*[:\.\-]|Question\s*\d*[:\.\-])\s*', caseSensitive: false), '')
            .trim();
        final aText = answerSplit.sublist(1).join(' ').trim();
        if (qText.isNotEmpty && aText.isNotEmpty) {
          items.add(FaqItemModel(question: qText, answer: aText));
        }
      }
    }

    if (items.isEmpty) {
      final lines = normalized.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      String currentQ = '';
      String currentA = '';

      for (final line in lines) {
        if (RegExp(r'^(?:Q\s*\d*[:\.\-]|Question\s*\d*[:\.\-])', caseSensitive: false).hasMatch(line)) {
          if (currentQ.isNotEmpty && currentA.isNotEmpty) {
            items.add(FaqItemModel(question: currentQ, answer: currentA));
            currentQ = '';
            currentA = '';
          }
          currentQ = line.replaceAll(RegExp(r'^(?:Q\s*\d*[:\.\-]|Question\s*\d*[:\.\-])\s*', caseSensitive: false), '').trim();
        } else if (RegExp(r'^(?:A\s*\d*[:\.\-]|Answer\s*\d*[:\.\-])', caseSensitive: false).hasMatch(line)) {
          currentA = line.replaceAll(RegExp(r'^(?:A\s*\d*[:\.\-]|Answer\s*\d*[:\.\-])\s*', caseSensitive: false), '').trim();
        } else if (currentA.isNotEmpty) {
          currentA += ' $line';
        } else if (currentQ.isNotEmpty) {
          currentQ += ' $line';
        }
      }

      if (currentQ.isNotEmpty && currentA.isNotEmpty) {
        items.add(FaqItemModel(question: currentQ, answer: currentA));
      }
    }

    return items;
  }
}

class MonographSectionModel {
  final String id;
  final String label;
  final String tag;
  final String content;
  final List<FaqItemModel>? faqItems;

  const MonographSectionModel({
    required this.id,
    required this.label,
    required this.tag,
    required this.content,
    this.faqItems,
  });
}

class MedicineDetailModel {
  final String? id;
  final String? medicineId;
  final String slug;
  final String medicineName;
  final String genericName;
  final String? categoryName;
  final String? categorySlug;
  final String? manufacturerName;
  final String? strength;
  final String dosageForm;
  final String? image;
  final double unitPrice;
  final String packSize;
  final bool rxRequired;
  final bool inStock;
  final int stockCount;
  final List<UnitPriceModel> unitPrices;
  final Map<String, String> medicineDetails;
  final List<MedicineModel> relatedMedicines;
  final List<MonographSectionModel> sections;

  const MedicineDetailModel({
    this.id,
    this.medicineId,
    required this.slug,
    required this.medicineName,
    required this.genericName,
    this.categoryName,
    this.categorySlug,
    this.manufacturerName,
    this.strength,
    this.dosageForm = 'Tablet',
    this.image,
    this.unitPrice = 0.0,
    this.packSize = '1 Unit',
    this.rxRequired = false,
    this.inStock = true,
    this.stockCount = 100,
    this.unitPrices = const [],
    this.medicineDetails = const {},
    this.relatedMedicines = const [],
    this.sections = const [],
  });

  factory MedicineDetailModel.fromJson(Map<String, dynamic> json) {
    final slugVal = json['slug']?.toString() ?? '';
    final rawName = json['medicine_name']?.toString() ??
        json['brand']?.toString() ??
        json['name']?.toString() ??
        'Medicine';
    final rawGeneric = json['generic_name']?.toString() ?? '';

    final productInfo = json['product_info'] as Map<String, dynamic>? ?? {};

    final rawPrices = productInfo['unit_prices'] as List<dynamic>? ??
        json['unit_prices'] as List<dynamic>? ??
        [];
    final unitPrices = rawPrices
        .map((p) => UnitPriceModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final rawDetails = json['medicine_details'] as Map<String, dynamic>? ?? {};
    final Map<String, String> detailsMap = {};
    rawDetails.forEach((key, value) {
      if (value != null && value.toString().trim().isNotEmpty) {
        detailsMap[key] = value.toString().trim();
      }
    });

    final rawRelated = json['related_medicines'] as List<dynamic>? ?? [];
    final related = rawRelated
        .map((r) => MedicineModel.fromJson(r as Map<String, dynamic>))
        .toList();

    final isRx = productInfo['rx_required'] == true ||
        productInfo['requires_prescription'] == true ||
        json['rx_required'] == true ||
        json['requires_prescription'] == true ||
        productInfo['rx_required']?.toString().toLowerCase() == 'true' ||
        json['rx_required']?.toString().toLowerCase() == 'true';

    final basePrice = _parseDouble(
      productInfo['unit_price'] ?? json['unit_price'],
      unitPrices.isNotEmpty ? unitPrices.first.price : 0.0,
    );

    final dosageForm = json['category_name']?.toString() ??
        productInfo['category_name']?.toString() ??
        productInfo['dosage_form']?.toString() ??
        'Tablet';

    final inStockVal = productInfo['in_stock'] is bool
        ? productInfo['in_stock'] as bool
        : (productInfo['is_available'] is bool
            ? productInfo['is_available'] as bool
            : (json['in_stock'] is bool
                ? json['in_stock'] as bool
                : true));

    final stockCountVal = _parseInt(
      productInfo['stock_count'] ?? json['stock_count'],
      100,
    );

    final sections = _buildMonographSections(detailsMap);

    return MedicineDetailModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      medicineId: json['medicine_id']?.toString(),
      slug: slugVal,
      medicineName: rawName,
      genericName: rawGeneric,
      categoryName: json['category_name']?.toString() ?? productInfo['category_name']?.toString(),
      categorySlug: json['category_slug']?.toString() ?? productInfo['category_slug']?.toString(),
      manufacturerName: json['manufacturer_name']?.toString() ?? productInfo['manufacturer_name']?.toString() ?? productInfo['manufacturer']?.toString(),
      strength: productInfo['strength']?.toString() ?? json['strength']?.toString(),
      dosageForm: dosageForm,
      image: productInfo['medicine_image']?.toString() ?? productInfo['image']?.toString() ?? json['medicine_image']?.toString(),
      unitPrice: basePrice,
      packSize: productInfo['pack_size']?.toString() ?? json['pack_size']?.toString() ?? (unitPrices.isNotEmpty ? unitPrices.first.unit : '1 Unit'),
      rxRequired: isRx,
      inStock: inStockVal,
      stockCount: stockCountVal,
      unitPrices: unitPrices,
      medicineDetails: detailsMap,
      relatedMedicines: related,
      sections: sections,
    );
  }

  static List<MonographSectionModel> _buildMonographSections(Map<String, String> details) {
    final List<MonographSectionModel> list = [];
    final Set<String> matchedKeys = {};

    // Key matcher helper
    String? getContentFor(List<String> candidateKeys) {
      for (final candidate in candidateKeys) {
        final candidateNorm = candidate.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (final entry in details.entries) {
          final entryNorm = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (entryNorm == candidateNorm && entry.value.trim().isNotEmpty) {
            matchedKeys.add(entry.key);
            return entry.value.trim();
          }
        }
      }
      return null;
    }

    void addSection(String id, String label, String tag, List<String> candidateKeys, {bool isFaq = false}) {
      final rawContent = getContentFor(candidateKeys);
      if (rawContent != null && rawContent.isNotEmpty) {
        final cleaned = cleanMonographText(rawContent);
        list.add(
          MonographSectionModel(
            id: id,
            label: label,
            tag: tag,
            content: cleaned,
            faqItems: isFaq ? FaqItemModel.parseFaqContent(rawContent) : null,
          ),
        );
      }
    }

    addSection('indications', 'Indications & Uses', 'Prescribing Info', ['Indications', 'Indication', 'Uses', 'Indications & Uses']);
    addSection('dosage', 'Dosage & Administration', 'Clinical Dosage', ['Dosage And Administration', 'Dosage', 'Administration', 'Dosage & Administration', 'Dosage and administration']);
    addSection('pharmacology', 'Pharmacology & Mechanism', 'Mode of Action', ['Pharmacology', 'Mode Of Action', 'Mode of Action', 'Mechanism of Action']);
    addSection('side_effects', 'Side Effects & Adverse Reactions', 'Safety & Tolerance', ['Side Effects', 'Adverse Effects', 'Side effects', 'Adverse Reactions']);
    addSection('precautions', 'Precautions & Warnings', 'Special Caution', ['Precautions And Warnings', 'Precautions', 'Warnings', 'Precautions & Warnings']);
    addSection('contraindications', 'Contraindications', 'Do Not Prescribe', ['Contraindications', 'Contraindication', 'Contra-indications']);
    addSection('pregnancy', 'Pregnancy & Lactation', 'Maternal Health', ['Pregnancy And Lactation', 'Pregnancy & Lactation', 'Pregnancy', 'Lactation']);
    addSection('interactions', 'Drug & Food Interactions', 'Concurrent Meds', ['Interaction', 'Interactions', 'Drug Interactions', 'Drug interactions']);
    addSection('overdose', 'Overdose & Special Populations', 'Emergency & Geriatrics', ['Overdose Effects', 'Use In Special Populations', 'Overdose', 'Special Populations']);
    addSection('therapeutic_class', 'Therapeutic Class', 'Classification', ['Therapeutic Class', 'Drug Classes', 'Therapeutic Classification']);
    addSection('description', 'Description & Composition', 'Product Overview', ['Description', 'Composition', 'Description & Composition']);
    addSection('storage', 'Storage & Handling', 'Storage Guidelines', ['Storage Conditions', 'Storage', 'Storage conditions']);
    addSection('faq', 'Frequently Asked Questions', 'FAQ', ['Faq', 'FAQ', 'Frequently Asked Questions'], isFaq: true);

    // Also include any other remaining monograph keys that weren't matched
    details.forEach((key, val) {
      if (!matchedKeys.contains(key) &&
          !key.toLowerCase().contains('meta') &&
          val.trim().isNotEmpty) {
        list.add(
          MonographSectionModel(
            id: key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
            label: key,
            tag: 'Monograph Info',
            content: cleanMonographText(val.trim()),
          ),
        );
      }
    });

    return list;
  }
}
