import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/features/profile/domain/address_model.dart';

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AddressRepository(apiClient);
});

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository(this._apiClient);

  Future<List<AddressModel>> getSavedAddresses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userAddresses);
      if (response.data != null && response.data['data'] != null) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<AddressModel>> addAddress(AddressModel address) async {
    final response = await _apiClient.post(
      ApiEndpoints.userAddresses,
      data: address.toJson(),
    );
    if (response.data != null && response.data['data'] != null) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [address];
  }

  Future<List<AddressModel>> deleteAddress(String id) async {
    final response = await _apiClient.delete(ApiEndpoints.deleteUserAddress(id));
    if (response.data != null && response.data['data'] != null) {
      final list = response.data['data'] as List<dynamic>;
      return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
