import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({
    required String baseUrl,
    required String? token,
    Future<void> Function()? onUnauthorized,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {
              if (token != null && token.isNotEmpty) 'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
          ),
        ) {
    // Global 401 handling so the UI doesn't get stuck on "server error" after token invalidation.
    if (onUnauthorized != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (e, handler) async {
            if (e.response?.statusCode == 401) {
              await onUnauthorized();
            }
            handler.next(e);
          },
        ),
      );
    }
  }

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(String path, {Map<String, dynamic>? queryParameters}) async {
    final res = await _dio.get<dynamic>(path, queryParameters: queryParameters);
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> postJson(String path, {Map<String, dynamic>? data}) async {
    final res = await _dio.post<dynamic>(path, data: data);
    if (res.data == null) {
      throw Exception('Empty response from server');
    }
    if (res.data is! Map) {
      throw Exception('Invalid response format from server');
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> putJson(String path, {Map<String, dynamic>? data}) async {
    final res = await _dio.put<dynamic>(path, data: data);
    return (res.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> patchJson(String path, {Map<String, dynamic>? data}) async {
    final res = await _dio.patch<dynamic>(path, data: data);
    if (res.data == null) {
      throw Exception('Empty response from server');
    }
    if (res.data is! Map) {
      throw Exception('Invalid response format from server');
    }
    return (res.data as Map).cast<String, dynamic>();
  }
}


