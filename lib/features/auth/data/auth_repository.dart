import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/core/storage/secure_storage.dart';
import 'package:meditouch/features/auth/domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  return AuthRepository(client, storage);
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  final userJson = await storage.getUserProfile();
  if (userJson != null) {
    return UserModel.fromJson(userJson);
  }
  return null;
});

class AuthRepository {
  final ApiClient _client;
  final SecureStorageService _storage;

  AuthRepository(this._client, this._storage);

  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {
        'identifier': emailOrPhone,
        'password': password,
      },
    );

    final respJson = response.data as Map<String, dynamic>;
    final data = (respJson['data'] is Map<String, dynamic>)
        ? respJson['data'] as Map<String, dynamic>
        : respJson;

    final token = data['access_token']?.toString() ?? '';
    final refreshToken = data['refresh_token']?.toString();
    final userJson = {
      'id': data['user_id'] ?? data['id'],
      'name': data['name'] ?? 'User',
      'phone': data['phone'],
      'email': data['email'],
      'role': data['role'] ?? 'PATIENT',
    };

    await _storage.saveTokens(accessToken: token, refreshToken: refreshToken);
    await _storage.saveUserProfile(userJson);

    return UserModel.fromJson(userJson);
  }

  Future<UserModel> register({
    required String name,
    required String phone,
    String? email,
    required String password,
    String gender = 'unspecified',
  }) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: {
        'name': name,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
        'password': password,
        'gender': gender,
      },
    );

    final respJson = response.data as Map<String, dynamic>;
    final data = (respJson['data'] is Map<String, dynamic>)
        ? respJson['data'] as Map<String, dynamic>
        : respJson;

    final token = data['access_token']?.toString() ?? '';
    final refreshToken = data['refresh_token']?.toString();
    final userJson = {
      'id': data['user_id'] ?? data['id'],
      'name': data['name'] ?? name,
      'phone': data['phone'] ?? phone,
      'email': data['email'] ?? email,
      'role': data['role'] ?? 'PATIENT',
    };

    await _storage.saveTokens(accessToken: token, refreshToken: refreshToken);
    await _storage.saveUserProfile(userJson);

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}
