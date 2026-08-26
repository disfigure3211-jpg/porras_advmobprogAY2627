import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

// Enhancement 3: Retrieve the cart using the selected user's ID
// and support adding products to the cart through DummyJSON.
class CartService {
  Future<Cart?> getCartByUser(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load cart for user $userId');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final carts = (decoded['carts'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Cart.fromJson)
        .toList();
    return carts.isEmpty ? null : carts.first;
  }

  Future<Cart> addProductToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add product to cart');
    }

    return Cart.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
