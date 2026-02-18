import 'package:dio/dio.dart';

bool isUnauthorizedError(Object error) {
  if (error is! DioException) return false;
  final code = error.response?.statusCode ?? -1;
  return code == 401;
}


