import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:project_state/model/cart.dart';
import 'package:project_state/service/cart_services.dart';

class CartController extends GetxController {
  var cartItem = <Cart>[].obs;
  final String sessionId = "guest_002";

  @override
  void onInit() {
    super.onInit();
    fetchCart();
  }

  Future<void> addToCart(Cart cart) async {
    await CartService.addToCart({
      'product_id': cart.productId,
      'name': cart.name,
      'size': cart.size,
      'sugar': cart.sugar,
      'price': cart.price,
      'qty': cart.qty,
      'total': cart.total,
      'image': cart.img,
      'session_id': sessionId,
    });

    await fetchCart(); // 🔥 IMPORTANT
  }

  Future<void> fetchCart() async {
    final items = await CartService.getCart(sessionId);
    cartItem.assignAll(items);
  }

  /// REMOVE
  Future<void> removeCartItem(int dbId) async {
    await CartService.deleteCart(dbId);
    cartItem.removeWhere((e) => e.dbId == dbId);
  }

  /// UPDATE QTY
  Future<void> updateQty(int index, int qty) async {
    final item = cartItem[index];
    await CartService.updateQty(item.dbId, qty);

    cartItem[index] = item.copyWith(qty: qty, total: item.price * qty);
  }

  // ✅ ADD THIS METHOD
  Future<void> clearCart() async {
    try {
      print('🗑️ Clearing cart for session: $sessionId');
      
      final success = await CartService.clearCart(sessionId);
      
      if (success) {
        cartItem.clear(); // Clear local cart
        print('✅ Cart cleared successfully');
      } else {
        print('❌ Failed to clear cart from database');
      }
    } catch (e) {
      print('❌ Error clearing cart: $e');
    }
  }

  double getSubTotal() {
    return cartItem.fold(0, (sum, e) => sum + e.total);
  }

  void increment(int index) {
    updateQty(index, cartItem[index].qty + 1);
  }

  void decrement(int index) {
    if (cartItem[index].qty > 1) {
      updateQty(index, cartItem[index].qty - 1);
    }
  }
}