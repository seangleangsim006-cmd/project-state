import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// ===============================
/// TELEGRAM SERVICE (UPDATED)
/// ===============================
class TelegramService {
  static const String _botToken = "8572789928:AAGrkyIyBHHz2a3eY9eAXeRdwChLKKgk8ak";
  static const String _chatId = "5604662811";

  static Future<bool> sendPaymentNotification({
    required String productName,
    required double amount,
    required String md5,
    required int productId,
  }) async {
    try {
      String dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      final message = '''
💰 PAYMENT SUCCESSFUL
━━━━━━━━━━━━━━━━━
☕ Product: $productName
💵 Amount: ${amount.toStringAsFixed(0)} KHR
📦 Product ID: #$productId
🔐 Transaction: $md5

🕒 Time: $dateTime
━━━━━━━━━━━━━━━━━
✅ Order confirmed & saved
''';

      final url = "https://api.telegram.org/bot$_botToken/sendMessage";

      final response = await http.post(
        Uri.parse(url),
        body: {
          "chat_id": _chatId,
          "text": message,
          "parse_mode": "HTML",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Telegram notification failed: $e");
      return false;
    }
  }
}
