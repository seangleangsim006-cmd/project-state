import 'package:get/get.dart';

class CategoryController  extends GetxController{
  var selectedCat = "All".obs;
  void setCategory(String cat){
     selectedCat.value=cat;
  }
}