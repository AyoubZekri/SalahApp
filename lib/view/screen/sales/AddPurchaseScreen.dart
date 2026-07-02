import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/PurchasesController.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/format_number.dart';
import '../../widget/CustomTextField.dart';
import '../../widget/CustomDropdown.dart';

class AddPurchaseScreen extends StatelessWidget {
  const AddPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PurchasesController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = const Color(0xFF800000);

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          "فاتورة شراء جديدة",
          style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomActions(controller, isDark, primaryColor),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<PurchasesController>(
          builder: (controller) {
            if (controller.statusrequest == Statusrequest.loadeng) {
              return Center(
                  child: CircularProgressIndicator(color: primaryColor));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomerSelection(controller, isDark, primaryColor, context),
                  const SizedBox(height: 16),
                  _buildAddProductButton(controller, isDark, primaryColor, context),
                  const SizedBox(height: 16),
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
                  _buildCartItems(controller, isDark, primaryColor),
                  const SizedBox(height: 20),
                  _buildInvoiceSummary(controller, isDark, primaryColor),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerSelection(PurchasesController controller, bool isDark, Color primaryColor, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_rounded, color: primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "اختر المورد (العميل)",
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (controller.selectedCustomer != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: Icon(Icons.business_rounded, color: primaryColor),
              ),
              title: Text(
                controller.selectedCustomer!.username ?? "بدون اسم",
                style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              subtitle: Text(
                controller.selectedCustomer!.phoneNumper ?? "",
                style: const TextStyle(fontFamily: "Cairo"),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () {
                  controller.selectedCustomer = null;
                  controller.update();
                },
              ),
            )
          else
            CustomDropdown<String>(
              value: controller.selectedCustomer?.uuid,
              items: controller.customers.map((cust) {
                return DropdownMenuItem<String>(
                  value: cust.uuid,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(cust.username ?? "",
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  ),
                );
              }).toList(),
              hintText: "اختر مورداً من القائمة",
              onChanged: (val) {
                controller.selectedCustomer = val == null
                    ? null
                    : controller.customers.firstWhere((e) => e.uuid == val);
                if (controller.selectedCustomer != null) {
                  controller.fetchCustomerDebt(controller.selectedCustomer!.uuid!);
                }
                controller.update();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAddProductButton(PurchasesController controller, bool isDark, Color primaryColor, BuildContext context) {
    return InkWell(
      onTap: () {
        _showAddProductDialog(controller, context, primaryColor);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart_rounded, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              "إضافة منتج",
              style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddProductDialog(PurchasesController controller, BuildContext context, Color primaryColor) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final qtyController = TextEditingController(text: "1");
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.defaultDialog(
      title: "إضافة منتج للشراء",
      titleStyle: TextStyle(
        fontFamily: "Cairo",
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: primaryColor,
      ),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("اسم المنتج",
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: nameController,
                hintText: "أدخل اسم المنتج",
                iconData: Icons.shopping_bag_outlined,
                validator: (v) => null,
              ),
              const SizedBox(height: 14),
              Text("سعر الشراء (دج)",
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: priceController,
                hintText: "0.0",
                iconData: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => null,
              ),
              const SizedBox(height: 14),
              Text("الكمية",
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: qtyController,
                hintText: "1",
                iconData: Icons.format_list_numbered,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: primaryColor),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "إلغاء",
                        style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final name = nameController.text;
                        final price = double.tryParse(priceController.text) ?? 0.0;
                        final qty = double.tryParse(qtyController.text) ?? 1.0;
                        if (name.isNotEmpty && price > 0) {
                          controller.addProductToCart(name, qty, price);
                          Get.back();
                        }
                      },
                      child: const Text(
                        "إضافة",
                        style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProductDialog(PurchasesController controller, BuildContext context, Color primaryColor, int index, Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item["name"]);
    final priceController = TextEditingController(text: item["price"].toString());
    final qtyController = TextEditingController(text: item["quantity"].toString());
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.defaultDialog(
      title: "تعديل المنتج",
      titleStyle: TextStyle(
        fontFamily: "Cairo",
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: primaryColor,
      ),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("اسم المنتج",
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: nameController,
                hintText: "أدخل اسم المنتج",
                iconData: Icons.shopping_bag_outlined,
                validator: (v) => null,
              ),
              const SizedBox(height: 14),
              Text("سعر الشراء (دج)",
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: priceController,
                hintText: "0.0",
                iconData: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => null,
              ),
              const SizedBox(height: 14),
              Text("الكمية",
                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: qtyController,
                hintText: "1",
                iconData: Icons.format_list_numbered,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: primaryColor),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "إلغاء",
                        style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final name = nameController.text;
                        final price = double.tryParse(priceController.text) ?? 0.0;
                        final qty = double.tryParse(qtyController.text) ?? 1.0;
                        if (name.isNotEmpty && price >= 0) {
                          controller.updateProductInCart(index, name, qty, price);
                          Get.back();
                        }
                      },
                      child: const Text(
                        "تعديل",
                        style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItems(PurchasesController controller, bool isDark, Color primaryColor) {
    if (controller.cartItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
        ),
        child: Column(
          children: [
            Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text(
              "لا توجد منتجات في السلة",
              style: TextStyle(fontFamily: "Cairo", color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.cartItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = controller.cartItems[index];
        final total = (item["price"] as double) * (item["quantity"] as double);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColor.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
          ),
          child: InkWell(
            onTap: () => _showEditProductDialog(controller, context, primaryColor, index, item),
            borderRadius: BorderRadius.circular(12),
            child: Row(
            children: [
              IconButton(
                onPressed: () => controller.removeProductFromCart(item["uuid"]),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: "حذف",
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["name"],
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "الكمية: ${item["quantity"]} x ${item["price"]} دج",
                      style: const TextStyle(fontFamily: "Cairo", fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                "${formatAmount(total)} دج",
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildInvoiceSummary(PurchasesController controller, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("الإجمالي الفرعي", style: TextStyle(fontFamily: "Cairo", color: Colors.grey)),
              Text(
                "${formatAmount(controller.subtotal)} دج",
                style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("الخصم الممنوح (دج)", style: TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.discountController,
                hintText: "0.0",
                iconData: Icons.local_offer_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("المبلغ المدفوع (دج)", style: TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.paidAmountController,
                hintText: "0.0",
                iconData: Icons.payments_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => null,
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          if (controller.selectedCustomer != null && controller.customerOldDebt != 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(controller.customerOldDebt > 0 ? "ديون المورد السابقة (أنت تساله)" : "ديون المورد السابقة (يسالك)",
                      style: TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.amber.shade800)),
                  Text("${formatAmount(controller.customerOldDebt.abs())} دج",
                      style: TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      (controller.customerOldDebt - (controller.netTotal - controller.paidAmount)) > 0
                          ? "ديون المورد بعد الشراء (أنت تساله)"
                          : "ديون المورد بعد الشراء (يسالك)",
                      style: const TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green)),
                  Text(
                      "${formatAmount((controller.customerOldDebt - (controller.netTotal - controller.paidAmount)).abs())} دج",
                      style: const TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                ],
              ),
            ),
            const Divider(height: 24, thickness: 0.8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.selectedCustomer != null
                    ? ((controller.customerOldDebt - (controller.netTotal - controller.paidAmount)) > 0
                        ? "المبلغ الصافي المستحق (أنت تساله)"
                        : "المبلغ الصافي المستحق (يسالك)")
                    : "المبلغ الصافي المستحق",
                style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
              ),
              Text(
                controller.selectedCustomer != null
                    ? "${formatAmount((controller.customerOldDebt - (controller.netTotal - controller.paidAmount)).abs())} دج"
                    : "${formatAmount(controller.netTotal)} دج",
                style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(PurchasesController controller, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            controller.checkout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "حفظ فاتورة الشراء",
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
