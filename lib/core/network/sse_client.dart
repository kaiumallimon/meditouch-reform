import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meditouch/core/network/api_client.dart';

class SSEMessage {
  final String event;
  final String data;

  const SSEMessage({required this.event, required this.data});

  Map<String, dynamic>? get json {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

final sseClientProvider = Provider<SSEClient>((ref) {
  final dio = ref.watch(dioProvider);
  return SSEClient(dio);
});

class SSEClient {
  final Dio _dio;

  SSEClient(this._dio);

  Stream<SSEMessage> streamPost(
    String path, {
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
  }) async* {
    final response = await _dio.post<ResponseBody>(
      path,
      data: body,
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        },
      ),
    );

    final stream = response.data?.stream;
    if (stream == null) return;

    String currentEvent = 'message';
    String buffer = '';

    await for (final chunk in stream) {
      final text = utf8.decode(chunk);
      buffer += text;

      final lines = buffer.split('\n');
      buffer = lines.removeLast();

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        if (trimmed.startsWith('event:')) {
          currentEvent = trimmed.substring(6).trim();
        } else if (trimmed.startsWith('data:')) {
          final data = trimmed.substring(5).trim();
          yield SSEMessage(event: currentEvent, data: data);
        }
      }
    }
  }
}

