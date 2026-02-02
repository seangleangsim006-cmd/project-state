import 'package:get/get.dart';
import 'package:project_state/model/coffee.dart';

class SearchControllerr extends GetxController {
  var searchItem = <Product>[].obs;

  // Selected Category
  var selectedCat = "All".obs;

  @override
  void onInit() {
    super.onInit();
   // searchItem.assignAll(coffee);
  }

  void searching(String text) {
    text = text.toLowerCase();

    // searchItem.assignAll(
    //   coffee.where((item) {
    //     final matchText =
    //         item.name.toLowerCase().contains(text);

    //     final matchCategory = selectedCat.value == "All"
    //         ? true
    //         : item.category == selectedCat.value;

    //     return matchText && matchCategory;
    //   }).toList(),
    // );
  }
}
