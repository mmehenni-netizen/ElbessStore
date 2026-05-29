import 'package:flutter/material.dart';

class InventoryFilterModel {
  final RangeValues priceRange;
  final List<String> stockStatus;
  final List<String> sizes;
  final String? category;
  final String sortBy;
  final bool activeOnly;

  const InventoryFilterModel({
    this.priceRange = const RangeValues(0, 50000),
    this.stockStatus = const [],
    this.sizes = const [],
    this.category,
    this.sortBy = 'Price: High to Low',
    this.activeOnly = false,
  });

  InventoryFilterModel copyWith({
    RangeValues? priceRange,
    List<String>? stockStatus,
    List<String>? sizes,
    String? category,
    String? sortBy,
    bool? activeOnly,
  }) {
    return InventoryFilterModel(
      priceRange: priceRange ?? this.priceRange,
      stockStatus: stockStatus ?? List<String>.from(this.stockStatus),
      sizes: sizes ?? List<String>.from(this.sizes),
      category: category ?? this.category,
      sortBy: sortBy ?? this.sortBy,
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }

  InventoryFilterModel reset() {
    return const InventoryFilterModel();
  }

  bool get isActive {
    if (priceRange.start != 0 || priceRange.end != 50000) return true;
    if (stockStatus.isNotEmpty) return true;
    if (sizes.isNotEmpty) return true;
    if ((category ?? '').isNotEmpty) return true;
    if (sortBy != 'Price: High to Low') return true;
    if (activeOnly) return true;
    return false;
  }

  @override
  String toString() {
    return 'InventoryFilterModel(priceRange: ${priceRange.start}-${priceRange.end}, stockStatus: $stockStatus, sizes: $sizes, category: $category, sortBy: $sortBy, activeOnly: $activeOnly)';
  }
}
