import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:project_state/config/api_config.dart';
import 'package:project_state/model/cart.dart';
class CartService {
  static const baseUrl = "${ApiConfig.baseUrl}/api";

static Future<void> addToCart(Map data) async {
  print("ADD TO CART PAYLOAD => $data"); // 👈 keep this for debug

  final res = await http.post(
    Uri.parse("$baseUrl/cart"),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json', // 🔥 REQUIRED
      'ngrok-skip-browser-warning': 'true',
    },
    body: jsonEncode(data),
  );

  if (res.statusCode != 200 && res.statusCode != 201) {
    throw Exception(res.body);
  }
}



static Future<List<Cart>> getCart(String sessionId) async {
  final res = await http.get(
    Uri.parse("$baseUrl/cart/$sessionId"),
    headers: {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    },
  );

  if (res.statusCode != 200) {
    throw Exception(res.body);
  }

  final List list = jsonDecode(res.body);
  return list.map((e) => Cart.fromJson(e)).toList();
}


 static Future<void> deleteCart(int id) async {
    await http.delete(Uri.parse("$baseUrl/cart/$id"));
  }

  static Future<void> updateQty(int id, int qty) async {
    await http.put(
      Uri.parse("$baseUrl/cart/$id"),
      body: {'qty': qty.toString()},
    );
  }

    // ✅ ADD THIS METHOD
  static Future<bool> clearCart(String sessionId) async {
    try {
      final url = '$baseUrl/cart/clear/$sessionId';
      print('🗑️ Clearing cart: $url');
      
      final response = await http.delete(Uri.parse(url));
      
      print('📡 Clear Response Status: ${response.statusCode}');
      print('📄 Clear Response Body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in clearCart: $e');
      return false;
    }
  }
}
