import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefHelpers {
  static const String _keytoken = "auth token";
  static const String _keyStoreId = "store_id";
  static const String _keyStoreName = "store_name";
  static const String _keyFavoriteProductIds = "favorite_product_ids";
  static const String _keyCartItems = "cart_items";

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keytoken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keytoken);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keytoken);
  }

  static Future<void> saveStoreId(String storeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreId, storeId);
  }

  static Future<String?> getStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStoreId);
  }

  static Future<void> removeStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStoreId);
  }

  static Future<void> saveStoreName(String storeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStoreName, storeName);
  }

  static Future<String?> getStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStoreName);
  }

  static Future<void> removeStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyStoreName);
  }

  static Future<List<String>> getFavoriteProductIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavoriteProductIds) ?? <String>[];
  }

  static Future<void> saveFavoriteProductIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavoriteProductIds, ids);
  }

  static Future<bool> toggleFavoriteProductId(String productId) async {
    final ids = await getFavoriteProductIds();
    final set = ids.toSet();

    final alreadyFavorite = set.contains(productId);
    if (alreadyFavorite) {
      set.remove(productId);
    } else {
      set.add(productId);
    }

    await saveFavoriteProductIds(set.toList());
    return !alreadyFavorite;
  }

  static Future<bool> isFavoriteProduct(String productId) async {
    final ids = await getFavoriteProductIds();
    return ids.contains(productId);
  }

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyCartItems) ?? <String>[];

    return raw
        .map((item) => jsonDecode(item))
        .whereType<Map>()
        .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
        .toList();
  }

  static Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = items.map(jsonEncode).toList();
    await prefs.setStringList(_keyCartItems, encoded);
  }

  static Future<void> addCartItem(Map<String, dynamic> newItem) async {
    final items = await getCartItems();

    final productId = (newItem['productId'] ?? '').toString();
    final size = (newItem['size'] ?? '').toString();
    final quantityToAdd = (newItem['quantity'] as num?)?.toInt() ?? 1;

    final index = items.indexWhere(
      (item) =>
          item['productId'].toString() == productId &&
          item['size'].toString() == size,
    );

    if (index >= 0) {
      final current = (items[index]['quantity'] as num?)?.toInt() ?? 1;
      items[index]['quantity'] = current + quantityToAdd;
    } else {
      items.add(newItem);
    }

    await saveCartItems(items);
  }

  static Future<void> updateCartItemQuantity(
    String productId,
    String size,
    int quantity,
  ) async {
    final items = await getCartItems();
    final index = items.indexWhere(
      (item) =>
          item['productId'].toString() == productId &&
          item['size'].toString() == size,
    );

    if (index < 0) {
      return;
    }

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index]['quantity'] = quantity;
    }

    await saveCartItems(items);
  }

  static Future<void> removeCartItem(String productId, String size) async {
    final items = await getCartItems();
    items.removeWhere(
      (item) =>
          item['productId'].toString() == productId &&
          item['size'].toString() == size,
    );
    await saveCartItems(items);
  }
}
