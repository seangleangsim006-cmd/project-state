import 'package:get/get.dart';

class CounterController extends GetxController{
  var qty=1.obs;

  void increment(){
    qty.value++;
  }
  void decrement(){
    qty.value--;
  }
}