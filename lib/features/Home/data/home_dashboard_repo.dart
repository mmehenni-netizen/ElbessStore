import 'package:elbess_store/core/network/api_service.dart';

class HomeDashboardOrderItem {
  final String id;
  final String orderNumber;
  final String title;
  final String quantityLabel;
  final String priceLabel;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;
  final String imageAsset;

  const HomeDashboardOrderItem({
    required this.id,
    required this.orderNumber,
    required this.title,
    required this.quantityLabel,
    required this.priceLabel,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.imageAsset,
  });

  factory HomeDashboardOrderItem.fromJson(
    Map<String, dynamic> json, {
    required int fallbackIndex,
  }) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final status = (json['status'] ?? _statusFromFlags(json)).toString();
    final totalPrice = _extractTotalPrice(json);
    final quantity = _extractQuantity(json);
    final createdAt = DateTime.tryParse((json['createdAt'] ?? '').toString());
    final orderSuffix = id.length >= 4 ? id.substring(id.length - 4).toUpperCase() : '${fallbackIndex + 1}';
    final imageAsset = _assetForIndex(fallbackIndex);

    return HomeDashboardOrderItem(
      id: id,
      orderNumber: '#$orderSuffix',
      title: 'Order #$orderSuffix',
      quantityLabel: 'Qty: $quantity',
      priceLabel: totalPrice > 0 ? '${totalPrice.toStringAsFixed(totalPrice.truncateToDouble() == totalPrice ? 0 : 2)} dz' : '0 dz',
      totalPrice: totalPrice,
      status: status,
      createdAt: createdAt,
      imageAsset: imageAsset,
    );
  }

  static String _statusFromFlags(Map<String, dynamic> json) {
    if (json['delivered'] == true) return 'delivered';
    if (json['shipped'] == true) return 'shipped';
    if (json['prepared'] == true) return 'prepared';
    if (json['confirmed'] == true) return 'confirmed';
    if (json['canceled'] == true || json['cancelled'] == true) return 'cancelled';
    return 'prepared';
  }

  static double _extractTotalPrice(Map<String, dynamic> json) {
    final value = json['totalPrice'] ?? json['total_price'] ?? json['price'];
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _extractQuantity(Map<String, dynamic> json) {
    final value = json['quantity'];
    if (value is num) {
      return value.toInt();
    }

    final products = json['products'];
    if (products is List) {
      return products.fold<int>(0, (sum, item) {
        if (item is Map<String, dynamic>) {
          final quantity = item['quantity'];
          if (quantity is num) {
            return sum + quantity.toInt();
          }
        }
        return sum;
      });
    }

    return 1;
  }

  static String _assetForIndex(int index) {
    const assets = [
      'assets/Images/clothes/item1.png',
      'assets/Images/clothes/item2.png',
      'assets/Images/clothes/item3.png',
    ];

    return assets[index % assets.length];
  }
}

class WeeklyOverviewSummary {
  final int totalOrders;
  final double totalRevenue;
  final int deliveredCount;
  final List<double> ordersSeries;
  final List<double> revenueSeries;
  final List<double> deliveredSeries;
  final List<HomeDashboardOrderItem> recentOrders;

  const WeeklyOverviewSummary({
    required this.totalOrders,
    required this.totalRevenue,
    required this.deliveredCount,
    required this.ordersSeries,
    required this.revenueSeries,
    required this.deliveredSeries,
    required this.recentOrders,
  });

  factory WeeklyOverviewSummary.empty() {
    return const WeeklyOverviewSummary(
      totalOrders: 0,
      totalRevenue: 0,
      deliveredCount: 0,
      ordersSeries: [0, 0, 0, 0, 0, 0, 0],
      revenueSeries: [0, 0, 0, 0, 0, 0, 0],
      deliveredSeries: [0, 0, 0, 0, 0, 0, 0],
      recentOrders: <HomeDashboardOrderItem>[],
    );
  }

  factory WeeklyOverviewSummary.fromOrders(List<HomeDashboardOrderItem> orders) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final ordersSeries = List<double>.filled(7, 0);
    final revenueSeries = List<double>.filled(7, 0);
    final deliveredSeries = List<double>.filled(7, 0);
    var deliveredCount = 0;
    var totalRevenue = 0.0;

    for (var index = 0; index < orders.length; index++) {
      final order = orders[index];
      final orderDate = order.createdAt;
      final weekIndex = orderDate == null
          ? index % 7
          : orderDate.difference(weekStart).inDays;

      final normalizedIndex = weekIndex.clamp(0, 6);
      final orderPrice = order.totalPrice;
      final isDelivered = order.status.toLowerCase() == 'delivered';

      ordersSeries[normalizedIndex] += 1;
      revenueSeries[normalizedIndex] += orderPrice;
      if (isDelivered) {
        deliveredSeries[normalizedIndex] += 1;
        deliveredCount += 1;
      }
      totalRevenue += orderPrice;
    }

    final recentOrders = List<HomeDashboardOrderItem>.from(orders)
      ..sort((left, right) {
        final leftDate = left.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate = right.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });

    return WeeklyOverviewSummary(
      totalOrders: orders.length,
      totalRevenue: totalRevenue,
      deliveredCount: deliveredCount,
      ordersSeries: ordersSeries,
      revenueSeries: revenueSeries,
      deliveredSeries: deliveredSeries,
      recentOrders: recentOrders,
    );
  }
}

class HomeDashboardRepository {
  final ApiService _apiService = ApiService();

  Future<WeeklyOverviewSummary> getWeeklyOverview(String storeId) async {
    final orders = await getOrders(storeId);
    return WeeklyOverviewSummary.fromOrders(orders);
  }

  Future<List<HomeDashboardOrderItem>> getOrders(String storeId) async {
    try {
      final response = await _apiService.post('/GetAllOrders', {'StoreId': storeId});

      if (response is! Map<String, dynamic>) {
        throw Exception('Unexpected server response');
      }

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to fetch orders');
      }

      final rawOrders = response['orders'];
      if (rawOrders is! List) {
        throw Exception('Unexpected server response');
      }

      return rawOrders
          .whereType<Map<String, dynamic>>()
          .mapIndexed(
            (index, order) => HomeDashboardOrderItem.fromJson(
              order,
              fallbackIndex: index,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }
}

extension _IterableMapIndexedExtension<T> on Iterable<T> {
  Iterable<R> mapIndexed<R>(R Function(int index, T item) transform) sync* {
    var index = 0;
    for (final item in this) {
      yield transform(index, item);
      index++;
    }
  }
}