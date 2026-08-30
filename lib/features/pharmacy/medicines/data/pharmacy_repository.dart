import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_detail_model.dart';
import 'package:meditouch/features/pharmacy/medicines/domain/medicine_model.dart';

final pharmacyRepositoryProvider = Provider<PharmacyRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PharmacyRepository(client);
});

class PharmacyRepository {
  final ApiClient _client;

  PharmacyRepository(this._client);

  Future<PaginatedMedicines> fetchMedicines({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? sortBy = 'name_asc',
    bool? inStockOnly,
    bool? requiresPrescription,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      'sort_by': sortBy,
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    if (category != null && category.isNotEmpty && category != 'ALL') {
      queryParams['category'] = category;
    }

    if (inStockOnly != null) {
      queryParams['in_stock_only'] = inStockOnly;
    }

    if (requiresPrescription != null) {
      queryParams['requires_prescription'] = requiresPrescription;
    }

    final response = await _client.get(
      ApiEndpoints.medicines,
      queryParameters: queryParams,
    );

    final respJson = response.data as Map<String, dynamic>;
    final data = (respJson['data'] is Map<String, dynamic>)
        ? respJson['data'] as Map<String, dynamic>
        : respJson;

    return PaginatedMedicines.fromJson(data);
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client.get(ApiEndpoints.categories);
      final respJson = response.data as Map<String, dynamic>;
      final rawList = (respJson['data'] is List)
          ? respJson['data'] as List
          : (respJson['categories'] is List)
              ? respJson['categories'] as List
              : [];

      return rawList.map((e) {
        if (e is Map) return e['category']?.toString() ?? e['name']?.toString() ?? '';
        return e.toString();
      }).where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return [
        'ALL',
        'TABLET',
        'SYRUP',
        'CAPSULE',
        'INJECTION',
        'DROP',
        'OINTMENT',
        'SUSPENSION',
      ];
    }
  }

  Future<MedicineDetailModel> fetchMedicineDetails(String slug) async {
    try {
      final response = await _client.get('${ApiEndpoints.medicines}/$slug/details');
      final respJson = response.data as Map<String, dynamic>;
      final data = (respJson['data'] is Map<String, dynamic>)
          ? respJson['data'] as Map<String, dynamic>
          : respJson;
      return MedicineDetailModel.fromJson(data);
    } catch (_) {
      // Fallback: try fetching basic medicine record
      final response = await _client.get('${ApiEndpoints.medicines}/$slug');
      final respJson = response.data as Map<String, dynamic>;
      final data = (respJson['data'] is Map<String, dynamic>)
          ? respJson['data'] as Map<String, dynamic>
          : respJson;
      return MedicineDetailModel.fromJson(data);
    }
  }
}
