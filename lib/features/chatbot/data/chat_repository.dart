import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/constants/api_endpoints.dart';
import 'package:meditouch/core/network/api_client.dart';
import 'package:meditouch/core/network/sse_client.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sseClient = ref.watch(sseClientProvider);
  return ChatRepository(apiClient, sseClient);
});

class ChatRepository {
  final ApiClient _apiClient;
  final SSEClient _sseClient;

  ChatRepository(this._apiClient, this._sseClient);

  Stream<SSEMessage> streamChatTurn({
    required String message,
    String? sessionId,
    String? confirmationToken,
  }) {
    return _sseClient.streamPost(
      ApiEndpoints.chatStream,
      body: {
        'message': message,
        'session_id': sessionId,
        'confirmation_token': confirmationToken,
      },
    );
  }

  Future<List<Map<String, dynamic>>> listSessions() async {
    final response = await _apiClient.get(ApiEndpoints.chatSessions);
    final data = response.data;
    if (data is Map<String, dynamic> && data['data'] is List) {
      return List<Map<String, dynamic>>.from(data['data'] as List);
    }
    return [];
  }

  Future<void> deleteSession(String sessionId) async {
    await _apiClient.delete('${ApiEndpoints.chatSessions}/$sessionId');
  }
}

