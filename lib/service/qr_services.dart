import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_state/config/api_config.dart';

class QrServices {
  static final String baseUrl = ApiConfig.baseUrl;

  /// ===============================
  /// GENERATE KHQR
  /// ===============================
  static Future<Map<String, dynamic>> getKHQR({
    required int productId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/bakong/checkout/$productId'),
      headers: {
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (res.statusCode != 200) {
      throw Exception(res.body);
    }

    return jsonDecode(res.body);
  }

  /// ===============================
  /// VERIFY PAYMENT
  /// ===============================
  static Future<bool> verifyPayment(String md5) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/bakong/verify'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode({'md5': md5}),
    );

    if (res.statusCode != 200) return false;

    final data = jsonDecode(res.body);

    print("VERIFY RESPONSE => $data");

    return data['status'] == 'SUCCESS';
  }

  /// ===============================
  /// SAVE ORDER AFTER PAYMENT
  /// ===============================
 static Future<bool> saveOrder({
  required int productId,
  required double amount,
  required String md5,
}) async {
  try {
    final res = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_id': productId, // 🔥 REQUIRED
        'amount': amount,
        'payment_method': 'Bakong',
        'transaction_ref': md5,
        'status': 'completed',
      }),
    );

    if (res.statusCode == 201) {
      return true;
    } else {
      print("SAVE ORDER FAILED: ${res.body}");
      return false;
    }
  } catch (e) {
    print("SAVE ORDER ERROR: $e");
    return false;
  }
}


  static Future<bool> placeOrder({
  required String sessionId,
  required double amount,
  required String md5,
}) async {
  final res = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/api/orders'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'session_id': sessionId,
      'amount': amount,
      'payment_method': 'Bakong',
      'transaction_ref': md5,
    }),
  );

  return res.statusCode == 201;
}
}
