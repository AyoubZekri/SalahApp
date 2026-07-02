import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/Colorapp.dart';

Future<bool> alertExitApp() {
  final isDark = Get.theme.brightness == Brightness.dark;
  Get.defaultDialog(
    backgroundColor: isDark ? AppColor.cardDark : AppColor.white,
    title: "Alert".tr,
    titleStyle: TextStyle(
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : AppColor.backgroundcolor,
    ),
    middleText: "هل تريد الخروج من التطبيق".tr,
    middleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
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
  return Future.value(true);
}
