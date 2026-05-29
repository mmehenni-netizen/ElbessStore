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
			size: _asString(json['size'] ?? json['Size']),
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

	static String _asString(dynamic value, {String fallback = ''}) {
		if (value == null) return fallback;
		final text = value.toString().trim();
		return text.isEmpty ? fallback : text;
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

		final parsedUri = Uri.tryParse(imageUrl);
		if (parsedUri != null && parsedUri.hasScheme && parsedUri.host.isNotEmpty) {
			return imageUrl;
		}

		return _joinUrl(_resolveImageBaseUrl(), imageUrl);
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
			name: _asString(json['name'] ?? json['Name']),
			price: _asDouble(json['price'] ?? json['Price']),
			rating: _asDouble(json['rating'] ?? json['Rating']),
			totalRates: _asInt(json['totalRates']),
			totalQuantity: _asInt(json['totalQuantity'] ?? json['TotalQuantity']),
			sizeQuantities: _extractSizeQuantities(json['sizeQuantities'] ?? json['SizeQuantities']),
			store: (json['store'] ?? json['Store'])?.toString(),
			imageUrls: urls,
			category: _asString(json['category'] ?? json['Category']),
			gender: _asString(json['gender'] ?? json['Gender']),
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

	static String _asString(dynamic value, {String fallback = ''}) {
		if (value == null) return fallback;
		final text = value.toString().trim();
		return text.isEmpty ? fallback : text;
	}

	static List<SizeQuantityModel> _extractSizeQuantities(dynamic value) {
		if (value is List) {
			return value
				.whereType<Map>()
				.map((item) => item.map(
					(key, itemValue) => MapEntry(key.toString(), itemValue),
				))
				.map(SizeQuantityModel.fromJson)
				.toList();
		}

		if (value is Map) {
			final normalized = value.map(
				(key, itemValue) => MapEntry(key.toString(), itemValue),
			);
			return [SizeQuantityModel.fromJson(normalized)];
		}

		return const [];
	}

	static String _resolveImageBaseUrl() {
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

	static String _joinUrl(String baseUrl, String path) {
		final normalizedBase = baseUrl.endsWith('/')
			? baseUrl.substring(0, baseUrl.length - 1)
			: baseUrl;
		final normalizedPath = path.startsWith('/') ? path : '/$path';
		return '$normalizedBase$normalizedPath';
	}
}
