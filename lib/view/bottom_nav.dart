import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:project_state/controller/bottom_nav_controller.dart';
import 'package:project_state/view/favorite_screen.dart';
import 'package:project_state/view/home_screem.dart';
import 'package:project_state/view/profile_screen.dart';
import 'package:project_state/view/search_screen.dart';
class BottomNav extends StatelessWidget {
  BottomNav({super.key});
  BottomNavController bottomNavController = Get.put(BottomNavController());
  List<Widget> screen=[
     HomeScreem(),
     SearchScreen(),
     FavoriteScreen(),
     ProfileScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(()=> screen[bottomNavController.selectedIndex.value]),
      bottomNavigationBar: Obx(
        ()=> BottomNavigationBar(
          currentIndex: bottomNavController.selectedIndex.value,
          type: BottomNavigationBarType.fixed,
          onTap: bottomNavController.selecting,
          selectedItemColor: const Color.fromARGB(255, 114, 36, 0),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.search),label: "Search"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite),label: "Favorite"),
            BottomNavigationBarItem(icon: Icon(Icons.person),label: "Profile")
          ]
        ),
      ),
    );
  }
}