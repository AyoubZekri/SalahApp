import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/SalesController.dart';
import '../../../core/constant/Colorapp.dart';
import 'ProductSelectionSheetContent.dart';

class AddProductButtonSection extends StatelessWidget {
  final SalesController controller;
  final bool isDark;

  const AddProductButtonSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showProductSelectionBottomSheet(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF800000),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF800000).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "إضافة منتج للفاتورة",
              style: TextStyle(
                fontFamily: "Cairo",
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColor.bgDark : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ProductSelectionSheetContent(
              controller: controller, isDark: isDark),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
