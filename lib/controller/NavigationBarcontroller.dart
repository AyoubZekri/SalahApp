import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../view/screen/HomeScreen.dart';
import '../view/screen/StatisticsScreen.dart';
import '../view/screen/SettingsScreen.dart';
import '../data/datasource/Remote/Home_data.dart';
import '../core/services/Services.dart';

class NavigationBarcontroller extends GetxController {
  int currentpage = 0;
  HomeData homeData = HomeData();

  double todaySales = 0.0;
  double uncollectedToday = 0.0;
  int totalCustomers = 0;
  int invoicesToday = 0;

  List<Widget> Screen = [
    const HomeScreen(),
    const StatisticsScreen(),
    const SettingsScreen(),
  ];

  List IconsScreen = [
    {'icon': Icons.home},
    {'icon': Icons.bar_chart_sharp},
    {'icon': Icons.settings},
  ];

  @override
  void onInit() {
    super.onInit();
    getStatistics();
    if (Get.isRegistered<RefreshService>()) {
      ever(Get.find<RefreshService>().refreshTrigger, (_) {
        getStatistics();
      });
    }
  }

  Future<void> getStatistics() async {
    final stats = await homeData.getStatistics();
    todaySales = stats["todaySales"] ?? 0.0;
    uncollectedToday = stats["uncollectedToday"] ?? 0.0;
    totalCustomers = stats["totalCustomers"] ?? 0;
    invoicesToday = stats["invoicesToday"] ?? 0;
    update();
  }

  @override
  void ChangePage(int i) {
    currentpage = i;
    if (i == 0) {
      getStatistics(); // Refresh data when switching back to home
    }
    update();
  }
}

