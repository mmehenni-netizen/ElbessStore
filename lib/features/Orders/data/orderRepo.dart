import 'package:elbess_store/core/network/api_service.dart';
import 'package:elbess_store/features/Orders/data/OrderModel.dart';

class OrderRepo {
  final ApiService _apiService = ApiService();

  Future<List<OrderModel>> getOrders(String id) async {
    try {
      final response = await _apiService.post('/GetAllOrders', {'storeId': id});

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch orders');
      }

      final rawOrders = response['orders'];
      if (rawOrders is! List) {
        return <OrderModel>[];
      }

      return rawOrders
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await _apiService.post('/UpdateOrderStatus', {
        'orderId': orderId,
        'status': status,
      });

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update order status');
      }

      final order = response['order'];
      if (order is Map<String, dynamic>) {
        return OrderModel.fromJson(order);
      }

      throw Exception('Unexpected server response');
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}