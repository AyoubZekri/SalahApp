import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controller/NavigationBarcontroller.dart';
import '../../core/constant/Colorapp.dart';
import '../widget/HomeScreen/CustemapparbuttonList.dart';



class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  @override
  Widget build(BuildContext context) {
    Get.put(NavigationBarcontroller());
    return GetBuilder<NavigationBarcontroller>(
      builder: (controller) => Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const CustemapparbuttonList(),
        // ignore: deprecated_member_use
        body: WillPopScope(
          child: controller.Screen.elementAt(controller.currentpage),
          onWillPop: () {
            Get.defaultDialog(
              backgroundColor: AppColor.white,
              title: "Alert".tr,
              titleStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColor.backgroundcolor,
              ),
              middleText: "هل تريد الخروج من التطبيق".tr,
              onConfirm: () {
                exit(0);
              },
              onCancel: () {
                Get.back();
              },
              buttonColor: AppColor.backgroundcolor,
              confirmTextColor: AppColor.primarycolor,
              cancelTextColor: AppColor.backgroundcolor,
            );

            return Future.value(false);
          },
        ),
      ),
    );
  }
}
