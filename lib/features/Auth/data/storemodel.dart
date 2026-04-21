class StoreModel {
	final String? id;
	final String name;
	final String location;
	final String description;
	final int activeProducts;
	final int totalRates;
	final double rating;
	final int revenus;
	final int shippingTime;
	final List<String> products;
	final int totalOrders;
	final String address;
	final String password;
	final bool isEmailVerified;
	final String? emailVerificationToken;
	final String logo;
	final int? version;

	const StoreModel({
		this.id,
		required this.name,
		required this.location,
		required this.description,
		required this.activeProducts,
		required this.totalRates,
		required this.rating,
		required this.revenus,
		required this.shippingTime,
		required this.products,
		required this.totalOrders,
		required this.address,
		required this.password,
		required this.isEmailVerified,
		this.emailVerificationToken,
		required this.logo,
		this.version,
	});

	factory StoreModel.fromJson(Map<String, dynamic> json) {
		final dynamic rawProducts = json['products'] ?? json['Products'] ?? const [];
		return StoreModel(
			id: json['_id']?.toString(),
			name: (_stringValue(json['name']) ?? _stringValue(json['Name']) ?? ''),
			location: (_stringValue(json['location']) ?? _stringValue(json['Location']) ?? ''),
			description: (_stringValue(json['description']) ?? _stringValue(json['Description']) ?? ''),
			activeProducts: _asInt(json['activeProducts'] ?? json['ActiveProducts']),
			totalRates: _asInt(json['totalRates'] ?? json['TotalRates']),
			rating: _asDouble(json['rating'] ?? json['Rating']),
			revenus: _asInt(json['revenus'] ?? json['Revenus']),
			shippingTime: _asInt(json['shippingTime'] ?? json['ShippingTime'], fallback: 3),
			products: (rawProducts as List<dynamic>? ?? const [])
					.map((item) => item.toString())
					.toList(),
			totalOrders: _asInt(json['totalOrders'] ?? json['TotalOrders']),
			address: (_stringValue(json['address']) ?? _stringValue(json['Address']) ?? ''),
			password: (_stringValue(json['password']) ?? _stringValue(json['Password']) ?? ''),
			isEmailVerified: json['isEmailVerified'] == true || json['IsEmailVerified'] == true,
			emailVerificationToken: _stringValue(json['emailVerificationToken']) ?? _stringValue(json['EmailVerificationToken']),
			logo: (_stringValue(json['logo']) ?? _stringValue(json['Logo']) ?? ''),
			version: json['__v'] is int ? json['__v'] as int : null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			if (id != null) '_id': id,
			'name': name,
			'location': location,
			'description': description,
			'activeProducts': activeProducts,
			'totalRates': totalRates,
			'rating': rating,
			'revenus': revenus,
			'shippingTime': shippingTime,
			'products': products,
			'totalOrders': totalOrders,
			'address': address,
			'password': password,
			'isEmailVerified': isEmailVerified,
			'emailVerificationToken': emailVerificationToken,
			'logo': logo,
			if (version != null) '__v': version,
		};
	}

	static int _asInt(dynamic value, {int fallback = 0}) {
		if (value is int) return value;
		if (value is num) return value.toInt();
		if (value is String) return int.tryParse(value) ?? fallback;
		return fallback;
	}

	static String? _stringValue(dynamic value) {
		if (value == null) return null;
		final text = value.toString().trim();
		return text.isEmpty ? null : text;
	}

	static double _asDouble(dynamic value, {double fallback = 0}) {
		if (value is double) return value;
		if (value is num) return value.toDouble();
		if (value is String) return double.tryParse(value) ?? fallback;
		return fallback;
	}
}