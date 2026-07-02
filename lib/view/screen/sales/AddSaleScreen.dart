import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/SalesController.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../../widget/sales/CustomerSelectionSection.dart';
import '../../widget/sales/AddProductButtonSection.dart';
import '../../widget/sales/CartItemsSection.dart';
import '../../widget/sales/InvoiceSummarySection.dart';
import '../../widget/sales/BottomActionsSection.dart';

class AddSaleScreen extends StatelessWidget {
  const AddSaleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SalesController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          "فاتورة بيع جديدة",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: BottomActionsSection(controller: controller, isDark: isDark),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<SalesController>(
          builder: (controller) {
            if (controller.statusrequest == Statusrequest.loadeng) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF800000)));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Customer Selection Area
                  CustomerSelectionSection(controller: controller, isDark: isDark),
                  const SizedBox(height: 16),

                  // 2. Add Product Trigger Button
                  AddProductButtonSection(controller: controller, isDark: isDark),
                  const SizedBox(height: 16),

                  // 3. Cart Items Title
                  Text(
                    "المنتجات المحددة في السلة (اضغط على المنتج لتعديل السعر/الكمية)",
                    style: TextStyle(
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 4. Cart Items List
                  CartItemsSection(controller: controller, isDark: isDark),
                  const SizedBox(height: 20),

                  // 5. Invoice summary cards
                  InvoiceSummarySection(controller: controller, isDark: isDark),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
