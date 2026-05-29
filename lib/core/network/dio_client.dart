import 'package:dio/dio.dart' show BaseOptions, Dio, InterceptorsWrapper;
import 'package:elbess_store/core/utils/pref_helpers.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _resolveBaseUrl(),
      headers: {"Content-Type": "application/json"},
    ),
  );
  DioClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await PrefHelpers.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
      ),
    );
  }
  Dio get dio => _dio;

  static String _resolveBaseUrl() {
    const overrideBaseUrl = String.fromEnvironment('API_BASE_URL');
    if (overrideBaseUrl.isNotEmpty) {
      return overrideBaseUrl;
    }

    if (kIsWeb) {
      return 'https://elbessstore.onrender.com';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://elbessstore.onrender.com';
    }

    return 'https://elbessstore.onrender.com';
  }
}
