import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:project_state/controller/cart_controller.dart';
import 'package:project_state/view/confirm_order.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});
  

  CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          "Cart",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(
        () => cartController.cartItem.isEmpty
            ? Center(
                child: Text(
                  "Cart Empty !!!",
                  style: TextStyle(fontSize: 20),
                ),
              )
            : Column(
                children: [
                  /// CART LIST
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: cartController.cartItem.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(
                            cartController.cartItem[index].productId.toString(),
                          ),
                          direction: DismissDirection.endToStart,
                          /// BACKGROUND (DELETE)
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                  
                          /// REMOVE ITEM
                          onDismissed: (direction) {
                            cartController.cartItem.removeAt(index);
                            cartController.cartItem.refresh();
                          },
                  
                          /// ITEM UI
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Container(
                              width: double.infinity,
                              height: 100,
                              decoration: BoxDecoration(
                                 border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 114, 36, 0),
                                                      width: 1.5,
                                                    ),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        cartController.cartItem[index].img,
                                        width: 85,
                                        height: 85,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartController
                                                .cartItem[index].name,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            "\$${cartController.cartItem[index].price}",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  cartController
                                                      .decrement(index);
                                                },
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 114, 36, 0),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "─",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Obx(
                                                () => Text(
                                                  '${cartController.cartItem[index].qty}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              InkWell(
                                                onTap: () {
                                                  cartController
                                                      .increment(index);
                                                },
                                                child: Container(
                                                  width: 25,
                                                  height: 25,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Color.fromARGB(
                                                          255, 114, 36, 0),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "+",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Spacer(),
                  /// SUMMARY
                  Container(
                    width: double.infinity,
                    height: 320,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Color.fromARGB(255, 254, 254, 254),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 30,
                        right: 30,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Summary",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Sub Total:",
                                  style: TextStyle(fontSize: 20)),
                              Text(
                                "\$${cartController.getSubTotal().toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Delivery:",
                                  style: TextStyle(fontSize: 20)),
                              Text("\$2.50",
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total:",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${(cartController.getSubTotal() + 2.50).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              // Get.snackbar(
                              //   "Success",
                              //   "Please Comfirm Your Address",
                              //   backgroundColor: Color.fromARGB(
                              //       204, 255, 255, 255),
                              // );
                              Get.to(ConfirmOrder(productId: 2,));

                            },
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Color.fromARGB(255, 114, 36, 0),
                                ),
                                child: Center(
                                  child: Text(
                                    "Check Out",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
