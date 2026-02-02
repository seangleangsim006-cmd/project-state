import 'package:get/get.dart';

class SugarController extends GetxController{
  var selectedIndex=0.obs;
  void setSeletedIndex(int index){
    selectedIndex.value=index;
  }

  RxString getSelectedSugar(){
    switch(selectedIndex.value){
      case 0:
        return "0%".obs;
      case 1:
        return "25%".obs;
      case 2:
        return "50%".obs;
      case 3:
        return "75%".obs;
      default:
        return "100%".obs;
    }
  }
}