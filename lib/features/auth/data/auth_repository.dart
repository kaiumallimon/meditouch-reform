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

class AuthRepository {
  final ApiClient _client;
  final SecureStorageService _storage;

  AuthRepository(this._client, this._storage);

  Future<UserModel> login({required String emailOrPhone, required String password}) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {
        'username': emailOrPhone,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final token = data['access_token']?.toString() ?? '';
    final refreshToken = data['refresh_token']?.toString();
    final userJson = data['user'] as Map<String, dynamic>? ?? {};

    await _storage.saveTokens(accessToken: token, refreshToken: refreshToken);
    await _storage.saveUserProfile(userJson);

    return UserModel.fromJson(userJson);
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}
