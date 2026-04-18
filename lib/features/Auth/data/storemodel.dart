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
		return StoreModel(
			id: json['_id']?.toString(),
			name: (json['Name'] ?? '') as String,
			location: (json['Location'] ?? '') as String,
			description: (json['Description'] ?? '') as String,
			activeProducts: _asInt(json['ActiveProducts']),
			totalRates: _asInt(json['totalRates']),
			rating: _asDouble(json['Rating']),
			revenus: _asInt(json['Revenus']),
			shippingTime: _asInt(json['ShippingTime'], fallback: 3),
			products: (json['products'] as List<dynamic>? ?? const [])
					.map((item) => item.toString())
					.toList(),
			totalOrders: _asInt(json['TotalOrders']),
			address: (json['Address'] ?? '') as String,
			password: (json['Password'] ?? '') as String,
			isEmailVerified: json['isEmailVerified'] == true,
			emailVerificationToken: json['EmailVerificationToken']?.toString(),
			logo: (json['Logo'] ?? '') as String,
			version: json['__v'] is int ? json['__v'] as int : null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			if (id != null) '_id': id,
			'Name': name,
			'Location': location,
			'Description': description,
			'ActiveProducts': activeProducts,
			'totalRates': totalRates,
			'Rating': rating,
			'Revenus': revenus,
			'ShippingTime': shippingTime,
			'products': products,
			'TotalOrders': totalOrders,
			'Address': address,
			'Password': password,
			'isEmailVerified': isEmailVerified,
			'EmailVerificationToken': emailVerificationToken,
			'Logo': logo,
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
}