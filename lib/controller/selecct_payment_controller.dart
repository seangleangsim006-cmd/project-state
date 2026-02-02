import 'package:get/get.dart';

class SelectPaymentController extends GetxController {
  RxInt isSelected = (-1).obs;

  void selecting(int index) {
    isSelected.value = index;
  }
}