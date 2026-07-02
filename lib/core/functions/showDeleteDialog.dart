import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constant/Colorapp.dart';

void showDeleteDialog({
  required String itemName,
  required VoidCallback onConfirm,
}) {
  final isDark = Get.theme.brightness == Brightness.dark;

  Get.defaultDialog(
    title: "تأكيد الحذف",
    titleStyle: TextStyle(
      fontFamily: "Cairo", 
      fontWeight: FontWeight.bold, 
      color: isDark ? Colors.white : Colors.red, 
      fontSize: 16
    ),
    backgroundColor: isDark ? AppColor.cardDark : Colors.white,
    radius: 18,
    contentPadding: const EdgeInsets.all(20),
    content: Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_forever_rounded, color: Colors.red, size: 54),
          const SizedBox(height: 14),
          Text(
            "هل تريد حذف $itemName؟",
            style: TextStyle(
              fontFamily: "Cairo", 
              fontSize: 15, 
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    confirm: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      onPressed: () {
        onConfirm();
        Get.back();
      },
      child: const Text(
        "نعم، حذف", 
        style: TextStyle(fontFamily: "Cairo", color: Colors.white, fontWeight: FontWeight.bold)
      ),
    ),
    cancel: OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Colors.grey),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      onPressed: () => Get.back(),
      child: const Text(
        "إلغاء", 
        style: TextStyle(fontFamily: "Cairo", color: Colors.grey, fontWeight: FontWeight.bold)
      ),
    ),
  );
}
