import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/product.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$host/products'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded is List<dynamic>
          ? decoded
          : (decoded['products'] as List<dynamic>? ?? []);
      return data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<Product> getById(int id) async {
    final response = await http.get(Uri.parse('$host/products/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load product $id');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // Backwards-compatible alias used elsewhere in the repo
  Future<List<Product>> getAllProducts() => fetchProducts();
}
