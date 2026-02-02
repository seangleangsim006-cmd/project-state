import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_state/controller/category_controller.dart';
import 'package:project_state/model/category.dart';
import 'package:project_state/model/coffee.dart';
import 'package:project_state/service/product_services.dart';
import 'package:project_state/view/cart_screen.dart';
import 'package:project_state/view/detail_screen.dart';

void main() {
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreem(),
    );
  }
}

class HomeScreem extends StatelessWidget {
  HomeScreem({super.key});

  final CategoryController catController = Get.put(CategoryController());
  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location", style: TextStyle(fontSize: 18)),
            Text(
              "Phnom Penh",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(CartScreen());
            },
            icon: const Icon(Icons.shopping_cart),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder<List<Product>>(
            future: productService.getProducts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              final data = snapshot.data ?? [];

              /// ✅ ONLY SPECIAL PRODUCTS
              final spacialProducts =
                  data.where((e) => e.special == true).toList();

              return Column(
                children: [
                  /// 🔍 Search
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(66, 158, 158, 158),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 📂 Category
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Category",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("See All"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// CATEGORY LIST
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: category.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: Obx(
                            () => Container(
                              width: 85,
                              decoration: BoxDecoration(
                                color: catController.selectedCat.value ==
                                        category[index].name
                                    ? const Color.fromARGB(255, 114, 36, 0)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 114, 36, 0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Image.network(
                                    category[index].image,
                                    height: 55,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    category[index].name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: catController.selectedCat.value ==
                                              category[index].name
                                          ? Colors.white
                                          : const Color.fromARGB(
                                              255, 114, 36, 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ⭐ SPACIAL
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Spacial",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("See All"),
                    ],
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 265,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: spacialProducts.length,
                      itemBuilder: (context, index) {
                        final item = spacialProducts[index];

                        /// ✅ FIXED PRICE LOGIC
                        final priceS = item.prices['S'] ?? 0;
                        final newPrice =
                            priceS - (priceS * item.discountPercent / 100);

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              Get.to(DetailScreen(coffee: item));
                            },
                            child: Container(
                              width: 210,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 114, 36, 0)),
                              ),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      item.image,
                                      height: 161,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.image),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(item.name,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500)),
                                            Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    size: 16,
                                                    color:
                                                        Colors.deepOrange),
                                                Text(item.rating.toString()),
                                              ],
                                            )
                                          ],
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.favorite_border),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(
                                        "\$${newPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "\$${priceS.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 114, 36, 0),
                                          borderRadius: BorderRadius.only(
                                            bottomRight:
                                                Radius.circular(14),
                                            topLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: const Center(
                                            child: Text("+",
                                                style: TextStyle(
                                                    color: Colors.white))),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Spacial Offer ",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text("See All"),
                    ],
                  ),
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          width: double.infinity,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: const Color.fromARGB(120, 114, 36, 0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      Image.network("${data[index].image}",width: 80,height: 80,fit: BoxFit.cover,),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${data[index].name}",
                                          style:
                                              TextStyle(fontSize: 18, fontWeight:
                                                  FontWeight.w500)),
                                      Text("\$${data[index].prices['S']}",
                                          style:
                                              TextStyle(fontSize: 18, fontWeight:
                                                  FontWeight.w500)),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Padding(
                                  padding:
                                      const EdgeInsets.all(10.0),
                                  child:
                                      Row(children: [Icon(Icons.star,color:
                                          Colors.deepOrange,size:
                                          18,), Text("${data[index].rating}"),],),
                                ),
                              ],
                            ),
                          ),
                        )
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
      ),
    );
  }
}
