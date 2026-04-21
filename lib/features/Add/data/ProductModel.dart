import 'package:flutter/foundation.dart';

class SizeQuantityModel {
	final String size;
	final int quantity;

	const SizeQuantityModel({
		required this.size,
		required this.quantity,
	});

	factory SizeQuantityModel.fromJson(Map<String, dynamic> json) {
		return SizeQuantityModel(
			size: (json['size'] ?? json['Size'] ?? '') as String,
			quantity: _asInt(json['quantity'] ?? json['Quantity']),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'size': size,
			'quantity': quantity,
		};
	}

	static int _asInt(dynamic value, {int fallback = 0}) {
		if (value is int) return value;
		if (value is num) return value.toInt();
		if (value is String) return int.tryParse(value) ?? fallback;
		return fallback;
	}
}

class ProductModel {
	final String? id;
	final String name;
	final double price;
	final double rating;
	final int totalRates;
	final int totalQuantity;
	final List<SizeQuantityModel> sizeQuantities;
	final String? store;
	final List<String> imageUrls;
	final String category;
	final String gender;
	final int? version;

	String get firstImageUrl {
		if (imageUrls.isEmpty) {
			return '';
		}
		return imageUrls.first;
	}

	String get fullImageUrl {
		final imageUrl = firstImageUrl;
		if (imageUrl.trim().isEmpty) {
			return '';
		}

		if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
			return imageUrl;
		}

		return _resolveImageBaseUrl() + imageUrl;
	}

	const ProductModel({
		this.id,
		required this.name,
		required this.price,
		required this.rating,
		required this.totalRates,
		required this.totalQuantity,
		required this.sizeQuantities,
		this.store,
		required this.imageUrls,
		required this.category,
		required this.gender,
		this.version,
	});

	factory ProductModel.fromJson(Map<String, dynamic> json) {
		// Handle imageUrl as either array or string (for backward compatibility)
		List<String> urls = [];
		final imageUrlData = json['imageUrl'] ?? json['ImageUrl'];
		if (imageUrlData is List) {
			urls = imageUrlData
				.map((item) => item?.toString() ?? '')
				.where((item) => item.isNotEmpty)
				.toList();
		} else if (imageUrlData is String && imageUrlData.isNotEmpty) {
			urls = [imageUrlData];
		}

		return ProductModel(
			id: json['_id']?.toString(),
			name: (json['name'] ?? json['Name'] ?? '') as String,
			price: _asDouble(json['price'] ?? json['Price']),
			rating: _asDouble(json['rating'] ?? json['Rating']),
			totalRates: _asInt(json['totalRates']),
			totalQuantity: _asInt(json['totalQuantity'] ?? json['TotalQuantity']),
			sizeQuantities: ((json['sizeQuantities'] ?? json['SizeQuantities']) as List<dynamic>? ?? const [])
					.whereType<Map<String, dynamic>>()
					.map(SizeQuantityModel.fromJson)
					.toList(),
			store: (json['store'] ?? json['Store'])?.toString(),
			imageUrls: urls,
			category: (json['category'] ?? json['Category'] ?? '') as String,
			gender: (json['gender'] ?? json['Gender'] ?? '') as String,
			version: json['__v'] is int ? json['__v'] as int : null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			if (id != null) '_id': id,
			'name': name,
			'price': price,
			'rating': rating,
			'totalRates': totalRates,
			'totalQuantity': totalQuantity,
			'sizeQuantities': sizeQuantities.map((item) => item.toJson()).toList(),
			'store': store,
			'imageUrl': imageUrls,
			'category': category,
			'gender': gender,
			if (version != null) '__v': version,
		};
	}

	static int _asInt(dynamic value, {int fallback = 0}) {
		if (value is int) return value;
		if (value is num) return value.toInt();
		if (value is String) return int.tryParse(value) ?? fallback;
		return fallback;
	}

	static double _asDouble(dynamic value, {double fallback = 0}) {
		if (value is double) return value;
		if (value is num) return value.toDouble();
		if (value is String) return double.tryParse(value) ?? fallback;
		return fallback;
	}

	static String _resolveImageBaseUrl() {
		const overrideBaseUrl = String.fromEnvironment('API_BASE_URL');
		if (overrideBaseUrl.isNotEmpty) {
			return overrideBaseUrl;
		}

		if (kIsWeb) {
			return 'http://localhost:3000';
		}

		if (defaultTargetPlatform == TargetPlatform.android) {
			return 'http://10.0.2.2:3000';
		}

		return 'http://localhost:3000';
	}
}
