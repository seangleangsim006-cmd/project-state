// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_state/controller/category_controller.dart';
// import 'package:project_state/model/coffee.dart';

// class DetailCategory extends StatelessWidget {
//   DetailCategory({super.key});

//   CategoryController categoryController = Get.put(CategoryController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Get.back();
//           },
//           icon: Icon(Icons.arrow_back_ios_new),
//         ),
//         title: Obx(() => Text(categoryController.selectedCat.value)),
//       ),

//       body: Obx(() {
//         final filterCat = 
//             .where(
//               (item) =>
//                   item.category.contains(categoryController.selectedCat.value),
//             )
//             .toList();

//         return Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: ListView.builder(
//             itemCount: filterCat.length,
//             itemBuilder: (context, index) {
//               return Padding(
//                 padding: const EdgeInsets.only(top: 5),
//                 child: Container(
//                   width: double.infinity,
//                   height: 90,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: const Color.fromARGB(120, 114, 36, 0),
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       /// MAIN CONTENT
//                       Row(
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.all(5.0),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.asset(filterCat[index].img),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   filterCat[index].name,
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 Text(
//                                   "\$${filterCat[index].price[0]['S']}",
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Spacer(),
//                           Column(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.all(10),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       color: Colors.deepOrange,
//                                       size: 18,
//                                     ),
//                                     Text("${filterCat[index].rating}"),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),

//                       /// ADD BUTTON (BOTTOM RIGHT, PADDING 0)
//                       Positioned(
//                         right: 0,
//                         bottom: 0,
//                         child: Container(
//                           width: 30,
//                           height: 30,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.only(
//                               bottomRight: Radius.circular(10),
//                               topLeft: Radius.circular(10),
//                             ),
//                             color: const Color.fromARGB(255, 114, 36, 0),
//                           ),
//                           child: Center(
//                             child: Text(
//                               "+",
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       }),
//     );
//   }
// }
