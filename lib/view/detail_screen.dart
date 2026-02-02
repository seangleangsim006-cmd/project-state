import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:project_state/controller/cart_controller.dart';
import 'package:project_state/controller/counter_controller.dart';
import 'package:project_state/controller/size_controller.dart';
import 'package:project_state/controller/sugar_controller.dart';
import 'package:project_state/model/cart.dart';
import 'package:project_state/model/coffee.dart';
import 'package:project_state/model/size.dart';

class DetailScreen extends StatelessWidget {
  Product coffee;
  DetailScreen({super.key, required this.coffee});
  List<String> sugar = ["25%", "50%", "100%"];
  SugarController sugarController = Get.put(SugarController());
  SizeController sizeController = Get.put(SizeController());
  CounterController counterController = Get.put(CounterController());
  CartController cartController = Get.put(CartController());

  double price() {
    String size = sizeController.getSelectedSize();
    return coffee.prices.containsKey(size) ? coffee.prices[size]! : 0.0;
  }

  double total = 0;
  @override
  Widget build(BuildContext context) {
    double top = 30, h = 5;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("${coffee.image}"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: const Color.fromARGB(84, 255, 255, 255),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 320,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                  left: 15,
                  right: 15,
                  bottom: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${coffee.name}",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "Quatity ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: const Color.fromARGB(
                                      255,
                                      114,
                                      36,
                                      0,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    if (counterController.qty.value > 1) {
                                      counterController.decrement();
                                    }
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          114,
                                          36,
                                          0,
                                        ),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "─",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Obx(
                                  () => Text(
                                    "${counterController.qty} ",
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: const Color.fromARGB(
                                        255,
                                        114,
                                        36,
                                        0,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                InkWell(
                                  onTap: () {
                                    counterController.increment();
                                  },
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                          255,
                                          114,
                                          36,
                                          0,
                                        ),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "+",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Obx(() {
                          total = price() * counterController.qty.value;
                          return Text(
                            "\$${total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "${coffee.description}This coffee delivers a smooth, rich flavor with gentle notes of caramel and roasted nuts. Carefully brewed for balance, it offers a warm aroma and a clean finish. Perfect for relaxing mornings or productive afternoons",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 98, 98, 98),
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Size",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 120,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: size.length,
                        itemBuilder: (context, index) {
                          final double top = 30 - (index * 6);
                          final double h = 5 + (index * 6);
                          return Padding(
                            padding: EdgeInsets.only(right: 10, top: top),
                            child: GestureDetector(
                              onTap: () {
                                sizeController.setSeletedIndex(index);
                              },
                              child: Obx(
                                () => Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color:
                                        (sizeController.selectedIndex.value !=
                                            index)
                                        ? Colors.white
                                        : const Color.fromARGB(255, 114, 36, 0),
                                    border: Border.all(
                                      width: 1.5,
                                      color:
                                          (sizeController.selectedIndex.value !=
                                              index)
                                          ? const Color.fromARGB(
                                              255,
                                              114,
                                              36,
                                              0,
                                            )
                                          : Colors.white,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(top: h),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            "${size[index].image}",
                                            height: 55,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            "${size[index].name}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  (sizeController
                                                          .selectedIndex
                                                          .value !=
                                                      index)
                                                  ? const Color.fromARGB(
                                                      255,
                                                      114,
                                                      36,
                                                      0,
                                                    )
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 22),
                    Text(
                      "Sugar",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 40,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: sugar.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                sugarController.setSeletedIndex(index);
                              },
                              child: Obx(
                                () => Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    color:
                                        (sugarController.selectedIndex.value ==
                                            index)
                                        ? const Color.fromARGB(255, 114, 36, 0)
                                        : Colors.white,
                                    border: Border.all(
                                      width: 1.5,
                                      color: const Color.fromARGB(
                                        255,
                                        114,
                                        36,
                                        0,
                                      ),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${sugar[index]}",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color:
                                            (sugarController
                                                    .selectedIndex
                                                    .value ==
                                                index)
                                            ? Colors.white
                                            : const Color.fromARGB(
                                                255,
                                                114,
                                                36,
                                                0,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        child: InkWell(
          onTap: () async {
            try {
              final double itemPrice = price();
              final int qty = counterController.qty.value;
              final double total = itemPrice * qty;

              await cartController.addToCart(
                Cart(
                  dbId: 0,
                  productId: coffee.id,
                  name: coffee.name,
                  size: sizeController.getSelectedSize(),
                  sugar: sugarController.getSelectedSugar().toString(),
                  price: itemPrice,
                  qty: qty,
                  total: total,
                  img: coffee.image,
                ),
              );

              Get.back();
              Get.snackbar(
                "Coffee Shop",
                "Product added to cart successfully",
                snackPosition: SnackPosition.BOTTOM,
              );
            } catch (e) {
              log("${e.toString()}");
              Get.snackbar(
                "Error",
                "Failed to add to cart",
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );

            }
          },

          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color.fromARGB(255, 114, 36, 0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                Text(
                  "Add to cart",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
