import 'package:dio/dio.dart';
import 'package:elbess_store/core/network/api_error.dart';
class ApiException {
  static ApiError handleError(DioException error) {
    final responseData = error.response?.data;
    final backendMessage = _extractMessage(responseData);
    final backendSuccess = _extractSuccess(responseData);
    final transportMessage = _extractTransportMessage(error);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiError(
          message: backendMessage ?? "Connection timeout",
          success: backendSuccess,
        );

      case DioExceptionType.sendTimeout:
        return ApiError(
          message: backendMessage ?? "Send timeout",
          success: backendSuccess,
        );

      case DioExceptionType.receiveTimeout:
        return ApiError(
          message: backendMessage ?? "Receive timeout",
          success: backendSuccess,
        );

      case DioExceptionType.badResponse:
        return ApiError(
          message: backendMessage ?? "Request failed",
          success: backendSuccess,
        );

      case DioExceptionType.cancel:
        return ApiError(
          message: backendMessage ?? "Request cancelled",
          success: backendSuccess,
        );

      case DioExceptionType.unknown:
        return ApiError(
          message: backendMessage ?? "Something went wrong",
          success: backendSuccess,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return ApiError(
          message: backendMessage ?? transportMessage ?? "Network error",
          success: backendSuccess,
        );
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return null;
  }

  static bool? _extractSuccess(dynamic data) {
    if (data is Map) {
      final success = data['success'];
      if (success is bool) {
        return success;
      }
    }

    return null;
  }
}

String? _extractTransportMessage(DioException error) {
  final message = error.message;
  if (message != null && message.trim().isNotEmpty) {
    return message;
  }

  final errorValue = error.error?.toString();
  if (errorValue != null && errorValue.trim().isNotEmpty) {
    return errorValue;
  }

  return null;
}
