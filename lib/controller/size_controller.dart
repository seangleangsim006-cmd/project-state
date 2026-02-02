import 'package:get/get.dart';

class SizeController extends GetxController{
  var selectedIndex=0.obs;
  void setSeletedIndex(int index){
    selectedIndex.value=index;
  }
  String getSelectedSize(){
       if(selectedIndex.value==0) return 'S';
       if(selectedIndex.value==1) return 'M';
       return 'L';
  }

}