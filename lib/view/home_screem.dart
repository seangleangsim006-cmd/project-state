import 'package:flutter/material.dart';
import 'package:project_state/model/category.dart';
import 'package:project_state/model/coffee.dart';

class HomeScreem extends StatelessWidget {
  const HomeScreem({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Location", style: TextStyle(fontSize: 18)),
            Text(
              "Phnom Penh",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [Icon(Icons.menu), SizedBox(width: 10)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(66, 158, 158, 158),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hint: Text("Search...", style: TextStyle(fontSize: 20)),
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Category",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("See All"),
              ],
            ),
            SizedBox(height: 15),
            // Show Category
            Container(
              width: double.infinity,
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: category.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: 85,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 114, 36, 0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Image.asset("${category[index].image}", height: 55),
                            SizedBox(height: 5),
                            Text(
                              "${category[index].name}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Spacial ",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("See All"),
              ],
            ),
            // Spacial
            Container(
              width: double.infinity,
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:coffee.length ,
                itemBuilder: (context, index) {
                  final newPrice = coffee[index].price[0]['S']!-coffee[index].price[0]['S']!*coffee[index].dis/100;
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color:  const Color.fromARGB(255, 114, 36, 0),)
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset("${coffee[index].img}",height: 130,width: double.infinity,fit: BoxFit.cover,)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${coffee[index].name}",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
                                    Row(
                                      children: [
                                        Icon(Icons.star,size: 16,color: Colors.deepOrange,),
                                        Text("${coffee[index].rating}"),
                                      ],
                                    )
                                  ],
                                ),
                                Spacer(),
                                Icon(Icons.favorite_border,color: const Color.fromARGB(255, 114, 36, 0),)
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 8,
                              ),
                              Text("\$${newPrice!.toStringAsFixed(2)}",style: TextStyle(fontSize: 19,fontWeight:FontWeight.w500 ),),
                              SizedBox(
                                width: 10,
                              ),
                              Text("\$${coffee[index].price[0]['S']!.toStringAsFixed(2)}",style: TextStyle(fontSize: 17,decoration: TextDecoration.lineThrough),)
                             ,
                             Spacer(),
                             Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 114, 36, 0),
                              borderRadius: BorderRadius.only(
                                bottomRight: Radius.circular(14)
                                ,topLeft: Radius.circular(10),
                              ),
                            ),
                            child: Center(child: Text("+",style: TextStyle(fontSize: 20,color: Colors.white),),),
                          )],
                          ),
                         
                        ],
                      ),
                    ),
                  );
                },
              ),
            )   
          ],
        ),
      ),
    );
  }
}
