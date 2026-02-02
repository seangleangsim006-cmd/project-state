import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:project_state/view/bottom_nav.dart';
void main(){
  runApp(
    MyApp(),
  );
}
class MyApp extends StatelessWidget {  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home:BottomNav(), 
    );
  }
}