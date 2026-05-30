import 'package:elbess_store/core/utils/pref_helpers.dart';
import 'package:elbess_store/features/Orders/data/OrderModel.dart';
import 'package:elbess_store/core/utils/size_config.dart';
import 'package:elbess_store/features/Orders/Widgets/customordertype.dart';
import 'package:elbess_store/features/Orders/Widgets/ordercard.dart';
import 'package:elbess_store/features/Orders/data/orderRepo.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'elbess_filter_bar.dart';

class Ordersbody extends StatefulWidget {
  const Ordersbody({super.key});

  @override
  State<Ordersbody> createState() => _OrdersbodyState();
}

class _OrdersbodyState extends State<Ordersbody> {
  int selectedIndex = 0;
  final List<String> type = ["All", "confirmed", "prepared", "shipped", "delivered", "canceled"];
  int selectedTimeIndex = 0;
  final List<String> timeFilters = ["All", "Today", "Last 7 days", "Last 30 days"];
  final OrderRepo _orderRepo = OrderRepo();
  final List<Map<String, String>> _orders = [];
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  final List<String> _statusOptions = [
    "confirmed",
    "prepared",
    "shipped",
    "delivered",
    "canceled",
  ];

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  Future<void> _showStatusSelector(int orderIndex) async {
    final selectedStatus = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final ds = SizeConfig.defaultSize!;
        final currentStatus = _orders[orderIndex]["status"] ?? "";
        return Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(ds * 2.4)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(ds * 2, ds, ds * 2, ds * 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: ds * 3.6,
                      height: ds * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(ds),
                      ),
                    ),
                  ),
                  Gap(ds * 1.4),
                  Text(
                    "Update Order Status",
                    style: TextStyle(fontFamily: "semi", fontSize: ds * 1.9),
                  ),
                  Gap(ds * 0.5),
                  Text(
                    "Order #${_orders[orderIndex]["number"]}",
                    style: TextStyle(fontFamily: "regular", fontSize: ds * 1.3, color: Colors.grey.shade600),
                  ),
                  Gap(ds * 1.5),
                  ..._statusOptions.map((status) {
                    final isSelected = status == currentStatus;
                    final color = _statusColor(status);
                    return Padding(
                      padding: EdgeInsets.only(bottom: ds * 0.9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(ds * 1.4),
                        onTap: () => Navigator.pop(context, status),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.symmetric(horizontal: ds * 1.2, vertical: ds * 1.05),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(ds * 1.4),
                            color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
                            border: Border.all(
                              color: isSelected ? color.withOpacity(0.5) : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: ds * 2.6,
                                height: ds * 2.6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? color.withOpacity(0.18) : Colors.white,
                                ),
                                child: Icon(_statusIcon(status), color: color, size: ds * 1.55),
                              ),
                              Gap(ds),
                              Expanded(
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                    fontFamily: "semi",
                                    fontSize: ds * 1.45,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected) Icon(Icons.check_circle_rounded, color: color, size: ds * 1.7),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selectedStatus == null || selectedStatus == _orders[orderIndex]["status"]) {
      return;
    }

    final orderId = _orders[orderIndex]["id"];
    if (orderId == null || orderId.isEmpty) {
      return;
    }

    try {
      await _orderRepo.updateOrderStatus(
        orderId: orderId,
        status: selectedStatus,
      );

      await getOrders();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update order status'),
        ),
      );
    }
  }

  String _statusLabel(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

    Color _statusColor(String value) {
      switch (value.toLowerCase()) {
        case 'confirmed':
          return const Color(0xFF7B8794);
        case 'prepared':
          return const Color(0xFFE67E22);
        case 'shipped':
          return const Color(0xFF27AE60);
        case 'delivered':
          return const Color(0xFFE74C3C);
        case 'canceled':
          return const Color(0xFFB03A2E);
        default:
          return Colors.grey;
      }
    }

    IconData _statusIcon(String value) {
      switch (value.toLowerCase()) {
        case 'confirmed':
          return Icons.verified_outlined;
        case 'prepared':
          return Icons.inventory_2_outlined;
        case 'shipped':
          return Icons.local_shipping_outlined;
        case 'delivered':
          return Icons.task_alt_outlined;
        case 'canceled':
          return Icons.cancel_outlined;
        default:
          return Icons.circle_outlined;
      }
    }
    
  Future<void> getOrders() async {
    final id = await PrefHelpers.getStoreId();
    if (id == null || id.trim().isEmpty) {
      return;
    }

    try {
      final res = await _orderRepo.getOrders(id.trim());
      if (!mounted) {
        return;
      }

      res.sort((left, right) {
        final leftTime = left.confirmationDate ?? left.deliveryDate ?? left.shippingDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightTime = right.confirmationDate ?? right.deliveryDate ?? right.shippingDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightTime.compareTo(leftTime);
      });

      setState(() {
        _orders
          ..clear()
          ..addAll(res.map(_mapOrderToUi));
      });
    } catch (_) {}
  }

  Map<String, String> _mapOrderToUi(OrderModel order) {
    final orderNumber = order.id.length >= 4
        ? order.id.substring(order.id.length - 4).toUpperCase()
        : order.id;
    final deliveryType = order.domicile ? 'home' : 'store';
    final address = order.location.trim();
    final locationText = address.isEmpty ? deliveryType : '$address / $deliveryType';
    final productName = order.type.trim().isNotEmpty
        ? order.type.trim()
      : (order.productName.trim().isNotEmpty)
        ? order.productName.trim()
        : (order.product?.trim().isNotEmpty == true ? order.product!.trim() : 'Order item');
    final customerName = order.name.trim().isNotEmpty ? order.name.trim() : 'Customer';
    final contactText = order.numero.trim().isNotEmpty ? '${order.numero} - $customerName' : customerName;
    final effectivePrice = order.price > 0 ? order.price : order.productPrice * order.quantity;
    final size = order.size.trim().isNotEmpty
        ? order.size.trim()
        : (order.products.isNotEmpty && order.products.first.size.trim().isNotEmpty
            ? order.products.first.size.trim()
            : '-');

    return {
      "id": order.id,
      "number": orderNumber,
      "status": order.status,
      "price": effectivePrice > 0 ? '${effectivePrice.toStringAsFixed(2)} dz' : '0 dz',
      "name": productName,
      "qty": '${order.quantity}x / $size',
      "customer": contactText,
      "colors": order.products.isEmpty ? 'no color' : order.products.first.color,
      "location": locationText,
      // time: prefer confirmationDate, then deliveryDate, then shippingDate
      "timeRaw": (order.confirmationDate ?? order.deliveryDate ?? order.shippingDate)?.toIso8601String() ?? '',
      "time": (order.confirmationDate ?? order.deliveryDate ?? order.shippingDate)?.toLocal().toString().split('.').first ?? '',
    };
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  bool _hasActiveFilters() {
    return (selectedTimeIndex != 0) || (_rangeStart != null && _rangeEnd != null);
  }
  @override
  Widget build(BuildContext context) {
        SizeConfig().init(context);

        final ds = SizeConfig.defaultSize!;
    final selectedType = type[selectedIndex];
    final selectedTime = timeFilters[selectedTimeIndex];

    List<Map<String, String>> filtered = selectedType == "All"
        ? _orders
        : _orders.where((order) => order["status"] == selectedType).toList();

    if (selectedTime != "All") {
      final now = DateTime.now();
      DateTime cutoff = now;
      if (selectedTime == 'Today') {
        cutoff = DateTime(now.year, now.month, now.day);
      } else if (selectedTime == 'Last 7 days') {
        cutoff = now.subtract(Duration(days: 7));
      } else if (selectedTime == 'Last 30 days') {
        cutoff = now.subtract(Duration(days: 30));
      }

      filtered = filtered.where((order) {
        final raw = order['timeRaw'] ?? '';
        if (raw.isEmpty) return false;
        try {
          final dt = DateTime.parse(raw).toLocal();
          if (selectedTime == 'Today') {
            return dt.year == now.year && dt.month == now.month && dt.day == now.day;
          }
          return dt.isAfter(cutoff) || dt.isAtSameMomentAs(cutoff);
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // apply custom date range filter if set
    if (_rangeStart != null && _rangeEnd != null) {
      final start = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
      final end = DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day, 23, 59, 59);
      filtered = filtered.where((order) {
        final raw = order['timeRaw'] ?? '';
        if (raw.isEmpty) return false;
        try {
          final dt = DateTime.parse(raw).toLocal();
          return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) && (dt.isBefore(end) || dt.isAtSameMomentAs(end));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    final visibleOrders = filtered;

    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: Padding(
          padding: EdgeInsets.only(left: ds * 2, right: ds * 2, bottom: ds * 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(height: ds * 5),
            Text("Manage Orders", style: TextStyle(fontFamily: "semi",fontSize: ds * 2.3)),
            Gap(ds * 3),
            // Elbess branded filter bar replaces older chips + filter button
            ElbessFilterBar(
              onFilterChanged: (status, period) {
                setState(() {
                  if (status == null || status == 'All') {
                    selectedIndex = 0;
                  } else {
                    final idx = type.indexOf(status);
                    selectedIndex = idx >= 0 ? idx : 0;
                  }

                  if (period == null) {
                    selectedTimeIndex = 0;
                  } else if (period == 'Today') {
                    selectedTimeIndex = 1;
                  } else if (period == 'Last 7 days') {
                    selectedTimeIndex = 2;
                  } else if (period == 'Last 30 days') {
                    selectedTimeIndex = 3;
                  } else {
                    selectedTimeIndex = 0;
                  }
                });
              },
            ),
              Gap(ds * 2),
              // show selected range and clear button
              if (_rangeStart != null && _rangeEnd != null)
                Padding(
                  padding: EdgeInsets.only(bottom: ds * 1.2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'From ${_formatDate(_rangeStart!)} to ${_formatDate(_rangeEnd!)}',
                          style: TextStyle(fontFamily: 'regular', fontSize: ds * 1.2, color: Colors.black87),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() { _rangeStart = null; _rangeEnd = null; }),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: ds, vertical: ds * 0.6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text('Clear', style: TextStyle(fontFamily: 'semi', fontSize: ds * 1.1)),
                        ),
                      ),
                    ],
                  ),
                ),

            ...List.generate(visibleOrders.length, (index) {
              final order = visibleOrders[index];
              final orderIndex = _orders.indexOf(order);
              return Padding(
                padding: EdgeInsets.only(bottom: ds * 1.5),
                child: Ordercard(
                  orderNumber: order["number"]!,
                  status: order["status"]!,
                  price: order["price"]!,
                  productName: order["name"]!,
                  qty: order["qty"]!,
                  customer: order["customer"]!,
                  colors: order["colors"]!,
                  location: order["location"]!,
                  time: order["time"] ?? '',
                  onUpdateStatus: () => _showStatusSelector(orderIndex),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}