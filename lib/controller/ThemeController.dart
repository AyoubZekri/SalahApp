import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/Services.dart';

class ThemeController extends GetxController {
  Myservices? myServices;
  
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      myServices = Get.find<Myservices>();
      String? savedTheme = myServices?.sharedPreferences?.getString('theme');
      if (savedTheme == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else {
        themeMode.value = ThemeMode.light;
      }
    } catch (e) {
      print("ThemeController Error reading SharedPreferences: $e");
    }
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    if (isDark) {
      themeMode.value = ThemeMode.dark;
      Get.changeThemeMode(ThemeMode.dark);
      myServices?.sharedPreferences?.setString('theme', 'dark');
    } else {
      themeMode.value = ThemeMode.light;
      Get.changeThemeMode(ThemeMode.light);
      myServices?.sharedPreferences?.setString('theme', 'light');
    }
    update();
  }
}
