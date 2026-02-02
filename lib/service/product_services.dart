import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_state/config/api_config.dart';
import 'package:project_state/model/coffee.dart';

class ProductService {
  static const String baseUrl = '${ApiConfig.baseUrl}/api';

  /// GET PRODUCTS
  Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['data'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load products: ${response.body}');
    }
  }

  /// ADD PRODUCT
  static Future<void> addProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add product: ${response.body}');
    }
  }
}
