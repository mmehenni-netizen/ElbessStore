class OrderModel {
	final String id;
	final String type;
	final String status;
	final String cancelReason;
	final String user;
	final String store;
	final String? product;
	final int quantity;
	final bool office;
	final bool domicile;
	final bool confirmed;
	final bool rejected;
	final bool prepared;
	final bool shipped;
	final bool delivered;
	final bool canceled;
	final DateTime? confirmationDate;
	final DateTime? preparationDate;
	final DateTime? shippingDate;
	final DateTime? deliveryDate;
	final DateTime? cancellationDate;
	final int? version;
	final List<OrderProductItem> products;

	const OrderModel({
		required this.id,
		required this.type,
		required this.status,
		required this.cancelReason,
		required this.user,
		required this.store,
		required this.product,
		required this.quantity,
		required this.office,
		required this.domicile,
		required this.confirmed,
		required this.rejected,
		required this.prepared,
		required this.shipped,
		required this.delivered,
		required this.canceled,
		required this.confirmationDate,
		required this.preparationDate,
		required this.shippingDate,
		required this.deliveryDate,
		required this.cancellationDate,
		required this.version,
		required this.products,
	});

	factory OrderModel.fromJson(Map<String, dynamic> json) {
		return OrderModel(
			id: (json['_id'] ?? '').toString(),
			type: (json['type'] ?? '').toString(),
			status: (json['status'] ?? '').toString(),
			cancelReason: (json['cancelReason'] ?? '').toString(),
			user: (json['user'] ?? '').toString(),
			store: (json['store'] ?? '').toString(),
			product: json['product']?.toString(),
			quantity: _toInt(json['quantity']),
			office: _toBool(json['office']),
			domicile: _toBool(json['domicile']),
			confirmed: _toBool(json['confirmed']),
			rejected: _toBool(json['rejected']),
			prepared: _toBool(json['prepared']),
			shipped: _toBool(json['shipped']),
			delivered: _toBool(json['delivered']),
			canceled: _toBool(json['canceled']),
			confirmationDate: _toDateTime(json['confirmationDate']),
			preparationDate: _toDateTime(json['preparationDate']),
			shippingDate: _toDateTime(json['shippingDate']),
			deliveryDate: _toDateTime(json['deliveryDate']),
			cancellationDate: _toDateTime(json['cancellationDate']),
			version: json['__v'] is int ? json['__v'] as int : null,
			products: (json['products'] is List)
					? (json['products'] as List)
							.whereType<Map<String, dynamic>>()
							.map(OrderProductItem.fromJson)
							.toList()
					: <OrderProductItem>[],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'_id': id,
			'type': type,
			'status': status,
			'cancelReason': cancelReason,
			'user': user,
			'store': store,
			'product': product,
			'quantity': quantity,
			'office': office,
			'domicile': domicile,
			'confirmed': confirmed,
			'rejected': rejected,
			'prepared': prepared,
			'shipped': shipped,
			'delivered': delivered,
			'canceled': canceled,
			'confirmationDate': confirmationDate?.toIso8601String(),
			'preparationDate': preparationDate?.toIso8601String(),
			'shippingDate': shippingDate?.toIso8601String(),
			'deliveryDate': deliveryDate?.toIso8601String(),
			'cancellationDate': cancellationDate?.toIso8601String(),
			'__v': version,
			'products': products.map((item) => item.toJson()).toList(),
		};
	}

	static int _toInt(dynamic value) {
		if (value is int) {
			return value;
		}
		if (value is num) {
			return value.toInt();
		}
		return int.tryParse(value?.toString() ?? '') ?? 0;
	}

	static bool _toBool(dynamic value) {
		if (value is bool) {
			return value;
		}
		if (value is num) {
			return value != 0;
		}
		final normalized = value?.toString().trim().toLowerCase();
		return normalized == 'true' || normalized == '1';
	}

	static DateTime? _toDateTime(dynamic value) {
		if (value == null) {
			return null;
		}
		return DateTime.tryParse(value.toString());
	}
}

class OrderProductItem {
	final String product;
	final int quantity;
	final double? price;
	final String size;
	final String color;

	const OrderProductItem({
		required this.product,
		required this.quantity,
		required this.price,
		required this.size,
		required this.color,
	});

	factory OrderProductItem.fromJson(Map<String, dynamic> json) {
		return OrderProductItem(
			product: (json['product'] ?? '').toString(),
			quantity: OrderModel._toInt(json['quantity']),
			price: (json['price'] is num) ? (json['price'] as num).toDouble() : double.tryParse(json['price']?.toString() ?? ''),
			size: (json['size'] ?? '').toString(),
			color: (json['color'] ?? '').toString(),
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'product': product,
			'quantity': quantity,
			'price': price,
			'size': size,
			'color': color,
		};
	}
}