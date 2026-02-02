import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:project_state/controller/cart_controller.dart';
import 'package:project_state/service/qr_services.dart';
import 'package:project_state/service/telegram_service.dart';
import 'package:project_state/view/bottom_nav.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:project_state/model/coffee.dart';
import 'package:project_state/controller/selecct_payment_controller.dart';
import 'package:project_state/model/payment_method.dart';

/// ===============================
/// CHECKOUT RESPONSE MODEL
/// ===============================
class CheckoutResponse {
  final String? qr;
  final String? md5;
  final double amount;

  CheckoutResponse({
    required this.qr,
    required this.md5,
    required this.amount,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      qr: json['qr'],
      md5: json['md5'],
      amount: (json['amount'] as num).toDouble(),
    );



  }
}

/// ===============================
/// API CALLS
/// ===============================
Future<Product> getProduct(int id) async {
  try {
    final url = 'https://hydremic-refreshingly-shellie.ngrok-free.dev/api/products';
    print('🔍 Fetching products from: $url');
    
    final res = await http.get(Uri.parse(url));
    
    print('📡 Response Status: ${res.statusCode}');
    print('📄 Response Body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load products (Status: ${res.statusCode})');
    }

    // Parse the response
    final Map<String, dynamic> jsonResponse = jsonDecode(res.body);
    
    // Check if success
    if (jsonResponse['success'] != true) {
      throw Exception('API returned success: false');
    }

    // Get the data array
    final List<dynamic> products = jsonResponse['data'];
    
    if (products.isEmpty) {
      throw Exception('No products found');
    }

    // Find the product with matching ID
    final productData = products.firstWhere(
      (p) => p['id'] == id,
      orElse: () => throw Exception('Product with ID $id not found'),
    );

    return Product.fromJson(productData);
  } catch (e) {
    print('❌ Error in getProduct: $e');
    rethrow;
  }
}


Future<CheckoutResponse> getCheckout(int id) async {
  final res = await http.get(
    Uri.parse(
      'https://hydremic-refreshingly-shellie.ngrok-free.dev/api/bakong/checkout/$id'
    ),
  );

  if (res.statusCode != 200) {
    throw Exception('Checkout failed: ${res.body}');
  }

  return CheckoutResponse.fromJson(jsonDecode(res.body));
}


/// ===============================
/// PAYMENT SCREEN
/// ===============================
class PaymentMethodd extends StatefulWidget {
  final int productId;

  const PaymentMethodd({
    super.key,
    required this.productId,
  });

  @override
  State<PaymentMethodd> createState() => _PaymentMethoddState();
}

class _PaymentMethoddState extends State<PaymentMethodd>
    with SingleTickerProviderStateMixin {
  SelectPaymentController paymentController =
      Get.put(SelectPaymentController());

  Product? product;
  CheckoutResponse? checkoutData;
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
  try {
    setState(() {
      isLoading = true;
      errorMessage = null;
      print('-------------CHECKOUT PAYLOAD => ${jsonEncode(checkoutData)}--------');
    });
    
    // ✅ Use widget.productId instead of hardcoded 2
    final productData = await getProduct(widget.productId);
    final checkout = await getCheckout(widget.productId);

    setState(() {
      product = productData;
      checkoutData = checkout;
      isLoading = false;
    });

    _animationController.forward();
  } catch (e) {
    setState(() {
      errorMessage = e.toString();
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final amount = checkoutData?.amount ?? 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? _loadingUI()
          : errorMessage != null
              ? _errorUI()
              : _contentUI(amount),
    );
  }

  Widget _loadingUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Loading payment details...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            ),
            const SizedBox(height: 24),
            const Text(
              "Oops! Something went wrong",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: loadData,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _contentUI(double amount) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildOrderSummary(amount),
                const SizedBox(height: 24),
                _buildPaymentMethodsSection(),
              ],
            ),
          ),
        ),
        _buildPayButton(),
      ],
    );
  }

  Widget _buildOrderSummary(double amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long, color: Colors.red[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "1 item",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${amount.toStringAsFixed(0)} KHR",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.payment, color: Colors.blue[400], size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: paymentMethod.length,
          itemBuilder: (context, index) => _buildPaymentMethodItem(index),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodItem(int index) {
    return Obx(() {
      final selected = paymentController.isSelected.value == index;
      return GestureDetector(
        onTap: () => paymentController.selecting(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.red[400]! : Colors.grey[200]!,
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: Colors.red.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Image.asset(
                  paymentMethod[index].image,
                  width: 32,
                  height: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  paymentMethod[index].name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.red[400] : Colors.black87,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? Colors.red[400] : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.red[400]! : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: selected ? Colors.white : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _payNow,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            shadowColor: Colors.red.withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 20),
              const SizedBox(width: 8),
              Text(
                "Pay ${checkoutData?.amount.toStringAsFixed(0) ?? '0'} KHR",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _payNow() {
    if (paymentController.isSelected.value != 0) {
      Get.snackbar(
        "Payment Method Required",
        "Please select Bakong payment method",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (checkoutData?.qr == null) {
      Get.snackbar(
        "Error",
        "QR code not available",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        icon: const Icon(Icons.error_outline, color: Colors.red),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BakongQRDialog(
        khqr: checkoutData!.qr!,
        amount: checkoutData!.amount,
        productName: product!.name,
        md5: checkoutData!.md5!,
        productId: widget.productId, // ✅ Pass product ID
      ),
    );
  }
}

/// ===============================
/// BAKONG QR DIALOG
/// ===============================
enum PaymentStatus { waiting, success }
class BakongQRDialog extends StatefulWidget {
  final String khqr;
  final String md5;
  final double amount;
  final String productName;
  final int productId; // ✅ Add product ID

  const BakongQRDialog({
    super.key,
    required this.khqr,
    required this.md5,
    required this.amount,
    required this.productName,
    required this.productId, // ✅ Add product ID
  });

  @override
  State<BakongQRDialog> createState() => _BakongQRDialogState();
}

class _BakongQRDialogState extends State<BakongQRDialog>
    with SingleTickerProviderStateMixin {

  bool verifying = false;
  bool isSaving = false;

  PaymentStatus status = PaymentStatus.waiting;

  late AnimationController _successController;
  late Animation<double> _successScale;
  @override
void initState() {
  super.initState();

  _successController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  _successScale = CurvedAnimation(
    parent: _successController,
    curve: Curves.elasticOut,
  );

  startVerifyLoop();
}
void startVerifyLoop() async {
  verifying = true;

  while (verifying && mounted) {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) break;

    final success = await QrServices.verifyPayment(widget.md5);
    print("VERIFY RESULT: $success");

    if (success) {
      verifying = false;
      setState(() {
        status = PaymentStatus.success;
      });

      _successController.forward();

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      await _saveOrderToDatabase();
      break;
    }
  }
}



Future<void> _saveOrderToDatabase() async {
  setState(() {
    isSaving = true;
  });

  print("🔍 Attempting to save order with product_id: ${widget.productId}");
  
  // ✅ Use widget.productId instead of hardcoded 2
  final success = await QrServices.saveOrder(
    productId: widget.productId,  // ✅ Fixed
    amount: widget.amount,
    md5: widget.md5,
  );

  if (!mounted) return;

  if (success) {
    await TelegramService.sendPaymentNotification(
      productName: widget.productName,
      amount: widget.amount,
      md5: widget.md5,
      productId: widget.productId,
    );

    Get.find<CartController>().cartItem.clear();
    _showSuccess();
  } else {
    Get.snackbar(
      "Order Save Failed",
      "Product ID ${widget.productId} doesn't exist in database. Payment was successful but order wasn't saved.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      icon: const Icon(Icons.error_outline, color: Colors.red),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 6),
    );
    
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(BottomNav());
    });
  }
}


void _showSuccess() {
  Future.delayed(const Duration(seconds: 1), () {
    if (Get.isDialogOpen == true) {
      Get.back(); // close QR dialog
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle,
                color: Colors.green, size: 72),
            SizedBox(height: 16),
            Text(
              "Payment Successful 🎉",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
      Get.offAll(BottomNav());
    });
  });
}



  void _showSaveError() {
    Get.snackbar(
      "Warning",
      "Payment successful but order save failed. Please contact support.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange[100],
      colorText: Colors.orange[900],
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
    );

    // Still navigate away
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAll(BottomNav());
    });
  }
@override
void dispose() {
  verifying = false;
  _successController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.red[400]!, Colors.red[600]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.qr_code_scanner,
                        size: 32, color: Colors.red[400]),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Scan to Pay",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSaving ? "Saving order..." : "Use your Bakong app to scan",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                 AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: status == PaymentStatus.waiting
      ? Column(
          key: const ValueKey("waiting"),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: QrImageView(
                data: widget.khqr,
                size: 220,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text("Waiting for payment..."),
          ],
        )
      : ScaleTransition(
          key: const ValueKey("success"),
          scale: _successScale,
          child: Column(
            children: const [
              Icon(Icons.check_circle,
                  color: Colors.green, size: 96),
              SizedBox(height: 12),
              Text(
                "Payment Successful 🎉",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
),

                  if (isSaving) ...[
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red[400]!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Saving order...",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text("Cancel"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  Get.snackbar(
                                    "Payment Processing",
                                    "Verifying your payment...",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.blue[100],
                                    colorText: Colors.blue[900],
                                    icon: const Icon(Icons.schedule,
                                        color: Colors.blue),
                                    margin: const EdgeInsets.all(16),
                                    borderRadius: 12,
                                  );
                                },
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text("Done"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}