import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:elbess_store/core/network/api_service.dart';
import 'package:elbess_store/core/utils/pref_helpers.dart';
import 'package:elbess_store/features/Add/data/ProductModel.dart';

class ProductRepo {
  final ApiService _apiService = ApiService();

  Future<ProductModel?> addProduct({
    required String name,
    required String description,
    required double price,
    required int totalQuantity,
    required String category,
    required String gender,
    required List<SizeQuantityModel> sizeQuantities,
    double? rating,
    int? totalRates,
    String? imageUrl,
    String? imagePath,
  }) async {
    try {
      final storeId = await PrefHelpers.getStoreId();
      if (storeId == null || storeId.trim().isEmpty) {
        throw Exception('Missing store id. Please login again.');
      }

      final formData = FormData.fromMap({
        'name': name.trim(),
        'description': description.trim(),
        'price': price.toString(),
        'totalQuantity': totalQuantity.toString(),
        'store': storeId.trim(),
        'category': category.trim(),
        'gender': gender.trim(),
        'sizeQuantities': jsonEncode(
          sizeQuantities.map((item) => item.toJson()).toList(),
        ),

        // Optional
        if (rating != null) 'rating': rating.toString(),
        if (totalRates != null) 'totalRates': totalRates.toString(),
        if (imageUrl != null && imageUrl.trim().isNotEmpty) 'imageUrl': imageUrl.trim(),
        if (imagePath != null && imagePath.trim().isNotEmpty)
          'Image': await MultipartFile.fromFile(imagePath.trim()),
      });

      final response = await _apiService.postMultipart('/AddProduct', formData);

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['creation'] != true) {
        throw Exception(response['message'] ?? 'Failed to add product');
      }

      final result = response['result'];
      if (result is Map<String, dynamic>) {
        return ProductModel.fromJson(result);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final response = await _apiService.post('/GetProduct', {'id': productId});

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch product');
      }

      final product = response['product'];
      if (product is Map<String, dynamic>) {
        return ProductModel.fromJson(product);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<ProductModel?> updateProduct({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int totalQuantity,
    required String category,
    required String gender,
    required List<SizeQuantityModel> sizeQuantities,
    double? rating,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'id': productId,
        'name': name.trim(),
        'description': description.trim(),
        'price': price.toString(),
        'totalQuantity': totalQuantity.toString(),
        'category': category.trim(),
        'gender': gender.trim(),
        'sizeQuantities': jsonEncode(
          sizeQuantities.map((item) => item.toJson()).toList(),
        ),
        if (rating != null) 'rating': rating.toString(),
        if (imagePath != null && imagePath.trim().isNotEmpty)
          'Image': await MultipartFile.fromFile(imagePath.trim()),
      });

      final response = await _apiService.postMultipart('/EditProduct', formData);

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update product');
      }

      final product = response['product'];
      if (product is Map<String, dynamic>) {
        return ProductModel.fromJson(product);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await _apiService.delete('/DeleteProduct', {'id': productId});

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      return response['deletion'] == true;
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  Future<List<ProductModel>> getInventory(String storeId) async {
    try {
      final response = await _apiService.post('/GetStoreProducts', {'storeId': storeId});

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch products');
      }

      final products = response['products'];
      if (products is! List) {
        throw Exception('Unexpected server response');
      }

      return products
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }
}