import 'package:dio/dio.dart';
import 'package:elbess_store/core/network/api_error.dart';
import 'package:elbess_store/core/network/api_exception.dart';
import 'package:elbess_store/core/network/api_service.dart';
import 'package:elbess_store/core/utils/pref_helpers%20.dart';
import 'package:elbess_store/features/Auth/data/storemodel.dart';

class AuthRepo {
  final ApiService _apiService = ApiService();

  Future<StoreModel?> login(String email, String password) async {
    try {
      final response = await _apiService.post('/SignIn', {
        'Address': email.trim().toLowerCase(),
        'Password': password,
      });

      if (response is ApiError) {
        throw response;
      }

      if (response is! Map<String, dynamic>) {
        throw ApiError(message: 'Unexpected server response');
      }

      if (response['success'] == true || response['find'] == true) {
        final token = response['token'];
        if (token is String && token.isNotEmpty) {
          await PrefHelpers.saveToken(token);
        }
        final result = response['result'];
        if (result is Map<String, dynamic>) {
          final store = StoreModel.fromJson(result);
          if (store.id != null && store.id!.trim().isNotEmpty) {
            await PrefHelpers.saveStoreId(store.id!.trim());
          }
          if (store.name.trim().isNotEmpty) {
            await PrefHelpers.saveStoreName(store.name.trim());
          }
          return store;
        }

        final store = StoreModel.fromJson(response);
        if (store.id != null && store.id!.trim().isNotEmpty) {
          await PrefHelpers.saveStoreId(store.id!.trim());
        }
        if (store.name.trim().isNotEmpty) {
          await PrefHelpers.saveStoreName(store.name.trim());
        }
        return store;
      }

      throw ApiError(message: response['message'] ?? 'An error occurred');
    } on DioException catch (e) {
      throw ApiException.handleError(e);
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  Future<StoreModel?> signup({
    required String email,
    required String password,
    required String name,
    required String location,
    required String description,
  }) async {
    try {
      final response = await _apiService.post('/SignUp', {
        'Address': email.trim().toLowerCase(),
        'Password': password,
        'Name': name.trim(),
        'Location': location.trim(),
        'Description': description.trim(),
      });

      if (response is ApiError) {
        throw response;
      }

      if (response is! Map<String, dynamic>) {
        throw ApiError(message: 'Unexpected server response');
      }

      if (response['creation'] == true) {
        final result = response['result'];
        if (result is Map<String, dynamic>) {
          final store = StoreModel.fromJson(result);
          if (store.id != null && store.id!.trim().isNotEmpty) {
            await PrefHelpers.saveStoreId(store.id!.trim());
          }
          if (store.name.trim().isNotEmpty) {
            await PrefHelpers.saveStoreName(store.name.trim());
          }
          return store;
        }

        final store = StoreModel.fromJson({
          'Address': email.trim().toLowerCase(),
          'Password': password,
          'Name': name.trim(),
          'Location': location.trim(),
          'Description': description.trim(),
          'ActiveProducts': 0,
          'totalRates': 0,
          'Rating': 0,
          'Revenus': 0,
          'ShippingTime': 3,
          'products': const [],
          'TotalOrders': 0,
          'isEmailVerified': false,
          'Logo': '/uploads/DefaultLogo.png',
        });
        if (store.id != null && store.id!.trim().isNotEmpty) {
          await PrefHelpers.saveStoreId(store.id!.trim());
        }
        if (store.name.trim().isNotEmpty) {
          await PrefHelpers.saveStoreName(store.name.trim());
        }
        return store;
      }

      throw ApiError(message: response['message'] ?? 'An error occurred');
    } on DioException catch (e) {
      throw ApiException.handleError(e);
    } on ApiError {
      rethrow;
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }
  
 
}