import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_state/controller/search_controller.dart';
import 'package:project_state/model/category.dart';
import 'package:project_state/view/detail_screen.dart';
class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});
  SearchControllerr searchController = Get.put(SearchControllerr());
  TextEditingController search = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        ()=> SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 114, 36, 0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 60),
                    width: 380,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: search,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                          hintText: "Search",
                        ),
                        onChanged: searchController.searching,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 65,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: category.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          searchController.selectedCat.value=category[index].name;
                          log("${searchController.selectedCat.value}");
                          searchController.searching(search.text);
                        },
                        child:Obx(
                          ()=> Container(
                              decoration: BoxDecoration(
                                color: (searchController.selectedCat.value == category[index].name)
                                    ?  const Color.fromARGB(255, 114, 36, 0)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 25,
                                  top: 10,
                                  bottom: 10,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset("${category[index].image}", width: 30),
                                    SizedBox(width: 10),
                                    Obx(
                                      ()=> Text(
                                        "${category[index].name}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: (searchController.selectedCat == category[index].name)
                                              ? const Color.fromARGB(255, 255, 255, 255)
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ),
                        ),
                      
                    );
                  },
                ),
              ),
          
              (searchController.searchItem.isEmpty)
                    ? Center(child: Text("Search Not Found !!!"))
                    : Obx(
                      ()=> ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: searchController.searchItem.length,
                          itemBuilder: (context, index) {
                            final item = searchController.searchItem[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12,left: 10,right: 10),
                              child: InkWell(
                                onTap: () {
                                  Get.to(DetailScreen(coffee: item));
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 2
                                      )
                                    ]
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset("${item.image}",width: 80,)),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 80,
                                            width: 200,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${item.name}",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "Price : \$${item.prices['S']}",
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(Icons.add_circle,color: const Color.fromARGB(255, 114, 36, 0),size:35 ,),
                                        SizedBox(
                                          width: 10,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ),
              
            ],
          ),
        ),
      ),
    );
  }
}
